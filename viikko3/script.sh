#! /usr/bin/env bash
set -euo pipefail

GITHUB_URL="https://github.com/Leama5/LinuxCourse.git"
OUTPUT_FILE="/home/ubuntu/LinuxCourse/viikko3/index.html"

check_disk_status(){
	local usage_percent="$1"
	local usage_number="${usage_percent%\%}"
	
	if [[ "$usage_number" -ge 80 ]]; then
		echo "WARNING"
	else
		echo "OK"
	fi
}

GENERATED_AT=$(date)
UPTIME_TEXT=$(uptime -p)
DISK_USAGE=$(df -h | grep -vE "tmpfs|udev" | head -2 | awk 'NR==2 {print $5}')
DISK_STATUS=$(check_disk_status "$DISK_USAGE")
MEM_TOTAL=$(free -m | awk 'NR == 2 {print $2}')
MEM_AVAILABLE=$(free -m | awk 'NR == 2 {print $7}')


TEMP_FILE=$(mktemp)

cat > "$TEMP_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Week 3 – Server Status Report</title>
    <style>
        body {
            font-family: system-ui, sans-serif;
            max-width: 900px;
            margin: 40px auto;
            padding: 0 20px;
            line-height: 1.6;
            background: #FFE4F6;
            color: #3B1E54;
        }

        h1, h2 {
            color: #705EFF;
        }

        section {
            margin: 24px 0;
            padding: 24px;
            background: white;
            border-radius: 12px;
        }

        .table-container {
            overflow-x: auto;
        }

        table {
            border-collapse: collapse;
            width: 100%;
        }

        th, td {
            border: 1px solid #F3B8E0;
            padding: 12px;
            text-align: left;
        }

        th {
            background: #F4E8FF;
	    color: #5A32A3;
        }

        code {
            background: #FCE7F3;
	    color: #D6336C;
            padding: 2px 5px;
            border-radius: 4px;
            overflow-wrap: anywhere;
        }

        a {
            color: #FF6082;
	    font-weight:bold;
        }

        .note {
            color: #7A5491;
        }
    </style>
</head>
<body>
    <header>
        <h1>Server Status Report</h1>
        <p>Week 3: Linux command line and Bash scripting</p>
        <p>This automated dashboard monitors real-time uptime, disk space and RAM usage of my virtual machine</p>
    </header>

    <section>
        <h2>Current server status</h2>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th scope="col">Information</th>
                        <th scope="col">Value</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <th scope="row">Report generated</th>
                        <td>$GENERATED_AT</td>
                    </tr>
                    <tr>
                        <th scope="row">Server uptime</th>
                        <td>$UPTIME_TEXT</td>
                    </tr>
                    <tr>
                        <th scope="row">Root filesystem disk usage</th>
                        <td>$DISK_USAGE</td>
                    </tr>
                    <tr>
                        <th scope="row">Disk space status</th>
                        <td>$DISK_STATUS</td>
                    </tr>
                    <tr>
                        <th scope="row">Total RAM</th>
                        <td>$MEM_TOTAL MiB</td>
                    </tr>
                    <tr>
                        <th scope="row">Available RAM</th>
                        <td>$MEM_AVAILABLE MiB</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <p>
            Disk space status is <strong>OK</strong> below 80% usage
            and <strong>WARNING</strong> at 80% or above.
        </p>

        <p class="note">
            Bash generates this report once per minute.
            Wait approximately 1–2 minutes and reload the page
            to see a new generation time.
        </p>
    </section>

    <section>
        <h2>Commands used</h2>
        <ul>
            <li>
                <code>date</code>:
                displays the current date, time and time zone
                using the format specified in the script.
            </li>
            <li>
                <code>uptime -p</code>:
                displays how long the server has been running.
            </li>
            <li>
                <code>df -h | grep -vE "tmpfs|udev" | head -2 | awk 'NR==2 {print \$5}'</code>:
                passes filesystem information to awk, which extracts
                the usage percentage from the second row and fifth column.
            </li>
            <li>
                <code>free -m</code>:
                displays memory information in mebibytes (MiB).
            </li>
        </ul>
    </section>

    <section>
        <h2>How the script works</h2>
        <p>
            The script collects server information using Linux commands
            and stores the results in Bash variables through command
            substitution. A function uses an if statement to determine
            the disk space status.
        </p>
        <p>
            The script generates a temporary HTML file and then moves
            the completed file into place as index.html.
            Nginx serves this file at /viikko3/.
        </p>
        <p>
            My disk space function looks like this:</p>
            <p><code>check_disk_status() {
            local usage_percent="\$1" 
            local usage_number="\${usage_percent%\%}" 

             if [[ "\$usage_number" -ge 80 ]]; then
                   echo "WARNING"
                else 
                    echo "OK"
                fi 
             }
	</p>
	<p>
            </code>
            So my function takes the usage percent and removes the % mark from it, so it is usable as a numerical value in my if statement. 
            The statement basically checks is the value smaller than 80% and if it is OK and if not then WARNING.
            
            As an example of piping i used a quite many piped command in my script to get disk usage percentage.
            <code> df -h | grep -vE "tmpfs|udev" | head -2 | awk 'NR==2 {print \$5}'</code> It lists all filesystems and filters out temporary virtual filesystems. 
            Head -2 keeps only the header and the first disk row and awk extracts the second row from the fifth column, which is the usage percentage. 
        </p>
    </section>

    <section>
        <h2>Scheduling</h2>
        <p>
            I used cron to schedule the updates. I added  the entry <code> * * * * * /home/ubuntu/LinuxCourse/viikko3/script.sh</code>
            to the user's crontab, so that it runs the script every minute.
            I ensured the schedule reboot with the same command as nginx which was <code>sudo systemctl enable cron</code>
            Also the script has execution permissions, to work properly.
        </p>
    </section>

    <section>
        <h2>Test results</h2>

        <h3>Syntax check and manual execution</h3>
        <p>
            At first running <code>bash -n script.sh</code> returned some outputs because of some missing attributes, but they were fixed.
            Now it works fine and manually executing bash code it generates <code> index.html</code> file and all metrics are displayed normally.

        </p>

        <h3>Disk space status tests</h3>
        <p>
            I tested the status logic using hard coded input values to attribute DISK_USAGE. 
            With 50% it said OK, and with both 80% and 90% it said WARNING as it should.
        </p>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th scope="col">Test input</th>
                        <th scope="col">Expected status</th>
                        <th scope="col">Actual status</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>50%</td>
                        <td>OK</td>
                        <td>OK</td>
                    </tr>
                    <tr>
                        <td>80%</td>
                        <td>WARNING</td>
                        <td>WARNING</td>
                    </tr>
                    <tr>
                        <td>90%</td>
                        <td>WARNING</td>
                        <td>WARNING</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <h3>Automatic updates</h3>
        <p>
            After configuring cron, I reloaded the page in the browser while making adjustment to this html file in script.sh 
            and it updated well every minute just as it was supposed to. 
            It also was seen on time for example it was Sat Nov 14 23:57:01 EET 2026 and after updating Sat Nov 14 23:58:01 EET 2026. 
        </p>

        <h3>Reboot test</h3>
        <p>
            I rebooted the VM with <code>sudo reboot</code> and week 3 and week 1 opened with no problems.
            With week 2 i had some problems after rebooting and i thought they were because i changed week 2 to different directory, but really i just mistyped the webaddress. 
            For the evidence the server uptime before rebooting was something like 5 days or so and now it's only 15 minutes. 
            </p>
    </section>

    <section>
        <h2>A problem solved or a lesson learned</h2>
        <p>
            I had one big problem with this weeks project and some smaller challenges.
            The biggest problem was in the beginning when I realised that my github repository was only made inside directory week2 
            which meant that i either had to make the week3 project inside week2 directory or move it inside a new directory. 
            For cleaner repository, I decided to move the week2 directory inside a new directory named LinuxCourse. 
            I had to stop Gunicorn and Python to make the change. 
            Also the used virtual environment that python uses had to be removed and made anew to the new directory.
            Systemd configuration had to be fixed with new paths and then restarting the service again.
            Finally i got the github repository to look clean and organized.
            
            I had some other small challenges throughout the project this week, but nothing i couldn't conquer!

        </p>
    </section>

    <footer>
        <p><a href="$GITHUB_URL">View the source code on GitHub</a></p>
    </footer>
</body>
</html>
EOF
mv "$TEMP_FILE" "$OUTPUT_FILE"
chmod 644 "$OUTPUT_FILE"

