import java.util.Scanner;

/* class AlarmClock
*
* This class contains all of the information to implement an alarm clock
* It stores up to two alarms.  You may set the alarms, check whether the
* alarm as gone off, update the time, etc.
*/

public class AlarmClock {
	
	// these are instance variables - each alarm clock has its
	// own copy of these variables
	// current time
	private int currentHour;
	private int currentMinute;
	private int currentSecond;
	
	// time of the alarm(s)
	private int[] alarmHour;
	private int[] alarmMinute;
	
	// whether alarm is on or off
	private boolean[] alarmOn;
	
	// this is the constructor - this is called when "new"
	// is called, when the object is first created
	// this contains code to initialize all variables in object
	// this is a special method - it has no return value (and no void)
	public AlarmClock() {
		alarmHour = new int[2];
		alarmMinute = new int[2];
		alarmOn = new boolean[2];
		
		// set both alarms to off
		turnOffAlarm(0);
		turnOffAlarm(1);
	}
	
	// now we put all of the methods
	// each method that we want code from outside the class to call is public
	// each method that we only want code from inside the class to call is private
	/* setAlarm
	 * inputs: alarm number, hour, minute
	 * outputs: none
	 * purpose: sets one of the alarms to the hour and minute specified
	 * It also turns on the alarm
	 */
	public void setAlarm(int alarm, int hour, int minute) {
		// make sure the alarm number is valid
		// set that alarm
		alarmHour[alarm] = hour;
		alarmMinute[alarm] = minute;
		
		// turn on alarm
		turnOnAlarm(alarm);
	}
	
	
	/* turnOnAlarm
	 * inputs: the alarm number
	 * outputs: none
	 * purpose: This turns on an alarm.  This assumes the alarm time has 
	 * already been set.
	 */
	public void turnOnAlarm(int alarm) {
		// make sure the alarm number is valid
		if (alarm < 2){
			// turn on alarm
			alarmOn[alarm] = true;
		}
	}
	
	
	/* turnOffAlarm
	 * inputs: the alarm number
	 * outputs: none
	 * purpose: This turns off an alarm. 
	 */
	public void turnOffAlarm(int alarm) {
		// make sure the alarm number is valid
		// turn off alarm
		alarmOn[alarm] = false;
	}
	
	
	/* setTime
	 * inputs: hour, minute, second
	 * outputs: none
	 * purpose: This updates the current time to the values
	 * passed in.
	 */
	public void setTime(int hour, int minute, int second) {
		currentHour = hour;
		currentMinute = minute;
		currentSecond = second;
	}
	
	
	/* tick
 	 * inputs: none
	 * outputs: none
	 * purpose: This gets called each second.  It updates the current time
	 * of the clock and sets of the alarm if necessary
	 */
    public void tick() {
        // print out tick, then tock, then tick, etc.
        System.out.println("Setting alarm 1 and alarm 2.");
        System.out.println(" ");
        
        while (alarmOn[0]==true || alarmOn[1]==true) {
            // increment the time
            currentSecond++;
            if(currentSecond % 2 == 0)
                System.out.println("Tick");
            else
                System.out.println("Tock");
            if (currentSecond == 60) {
                currentMinute++;
                currentSecond = 0;
            }
            if (currentMinute == 60) {
                currentHour++;
                currentMinute = 0;
            }
            if (currentHour == 24) {
                currentHour = 0;
                currentMinute = 0;
                currentSecond = 0;
            }
            System.out.println(currentHour + ":" + currentMinute + ":" + currentSecond);
            int x = 0;
            while (x < 2) {
                // check to see if an alarm should go off
                if (alarmHour[x] == currentHour && alarmMinute[x] == currentMinute) {
                    if (alarmOn[x] == true) {
                        soundAlarm();
                        if (currentSecond == 59) {
                            turnOffAlarm(x);
                        }
                    }
                }
                x++;
            }
        }
    }
	
	
	/* soundAlarm
	 * inputs: none
	 * outputs: none 
	 * purpose: this gets called by tick when the alarm goes off
	 *   It sounds an alarm 
	 */
	public void soundAlarm() {
		System.out.println("Alarm!!***********************");
	}
	
	
	public static void main(String[] args) {
		
		Scanner scan = new Scanner(System.in);
		AlarmClock set1 = new AlarmClock();
		System.out.print("Input current hour: ");
		int hour = scan.nextInt();
		System.out.print("Input current minute: ");
		int minute = scan.nextInt();
		System.out.print("Input current second: ");
		int second = scan.nextInt();
		set1.setTime(hour,minute,second);
		
		System.out.println("Setting alarm 1");
		System.out.print("Input alarm hour: ");
		int hour1 = scan.nextInt();
		System.out.print("Input alarm minute: ");
		int minute1 = scan.nextInt();
		System.out.print("Input alarm second: ");
		int second1 = scan.nextInt();
		set1.setAlarm(0, hour1, minute1);
		
		System.out.println("Setting alarm 2");
		System.out.print("Input alarm hour: ");
		int hour2 = scan.nextInt();
		System.out.print("Input alarm minute: ");
		int minute2 = scan.nextInt();
		System.out.print("Input alarm second: ");
		int second2 = scan.nextInt();
		set1.setAlarm(1, hour2, minute2);
		
		set1.tick();

	}
}
