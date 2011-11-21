/*
 Impy RoboBrrd
 --------------
 
 Nov 14, 2011
 robotgrrl.com
 
 Examples of how you can program your RoboBrrd!
 
 CC BY-SA
 */

#include <Servo.h> 
#include <Streaming.h>

Servo beakServo, rwingServo, lwingServo, rotationServo;

// Servos
int BEAK = 13;
int RWING = 12;
int LWING = 8;
int ROTATION = 7;
int HULA = 4;

// LEDs
int RED = 9;
int GREEN = 10;
int BLUE = 11;

// Misc
int SPKR = 6;
int LDR_R = A0;
int LDR_L = A1;

// Positions
int BEAK_OPEN = 75;
int BEAK_CLOSED = 30;
int BEAK_MIDDLE = 53;

int RWING_UP = 130;
int RWING_DOWN = 65;
int RWING_MIDDLE = 80;

int LWING_UP = 70;
int LWING_DOWN = 135;
int LWING_MIDDLE = 110;

int LEFT = 180;
int RIGHT = 0;
int MIDDLE = 90;


int pos = RWING_DOWN;
char c;
boolean stopped = false;
boolean forwards = true;

int ledR = 0;
int ledG = 0;
int ledB = 0;

int ledR_0 = 255;
int ledG_0 = 255;
int ledB_0 = 255;

boolean fadingRainbow = false;
int fadeCount = 0;
int fadeColour = 0;


int turn = 0;
boolean left = false;

int ldrLprev;
int ldrRprev;
int thresh = 30;
boolean chase = false;
boolean photovore = false;


void setup()  {
    
    Serial.begin(9600);
    
    // Attach all the servos
    beakServo.attach(BEAK);
    rwingServo.attach(RWING);
    lwingServo.attach(LWING);
    rotationServo.attach(ROTATION);
    
    // Set the servos
    beakServo.write(BEAK_MIDDLE);
    rwingServo.write(RWING_MIDDLE+20);
    lwingServo.write(LWING_MIDDLE-20);
    rotationServo.write(MIDDLE);
    
    // Set up all the other pins
    pinMode(HULA, OUTPUT);
    digitalWrite(HULA, LOW);
    
    pinMode(LDR_R, INPUT);
    pinMode(LDR_L, INPUT);
    
    pinMode(SPKR, OUTPUT);
    pinMode(RED, OUTPUT);
    pinMode(BLUE, OUTPUT);
    pinMode(GREEN, OUTPUT);
    
    // Random chirp!
    randomChirp();
    
} 


void loop() { 
    
    for(int i=0; i<5; i++) {
    digitalWrite(HULA, HIGH);
    delay(5);
    digitalWrite(HULA, LOW);
    delay(100);
    }
    
    delay(2000);
    
    //happy();
    //macarena();
    //beakTest();
    
}

// ------------
// D A N C E S
// ------------

void happy() {
    
    for(int i=0; i<3; i++) {
    rotationServo.write(MIDDLE+50);
    delay(500);
    
    rotationServo.write(MIDDLE-50);
    delay(500);
    }
    
    beakServo.write(BEAK_OPEN);
    delay(1000);
    
    beakServo.write(BEAK_CLOSED);
    delay(1000);
    
    delay(1000);
    
    for(int i=0; i<3; i++) {
        digitalWrite(HULA, HIGH);
        delay(5);
        digitalWrite(HULA, LOW);
        delay(100);
    }
    
    delay(1000);
    
    for(int i=0; i<3; i++) {
        rotationServo.write(MIDDLE+50);
        delay(500);
        
        rotationServo.write(MIDDLE-50);
        delay(500);
    }
    
    wingsWave();
    
    delay(1000);
    
    for(int i=0; i<3; i++) {
        digitalWrite(HULA, HIGH);
        delay(5);
        digitalWrite(HULA, LOW);
        delay(100);
    }
    
    delay(1000);
    
    delay(500);
    
}

void macarena() {
    
    playTone(700, 20);
    
    
    int sway = 5;
    int rest = 500;
    
    int angle = 60;
    
    for(int i=0; i<12; i++) {
        rotationServo.write(MIDDLE+angle+sway);
        delay(rest);
        rotationServo.write(MIDDLE+angle-sway);
        delay(rest);
    }
    
    for(int j=0; j<10; j++) {
        
        for(int i=0; i<2; i++) {
            rwingServo.write(RWING_DOWN);
            lwingServo.write(LWING_DOWN);
            rotationServo.write(MIDDLE+angle);
            
            
            rotationServo.write(MIDDLE+angle+sway);
            rwingServo.write(RWING_MIDDLE);
            delay(rest);
            
            rotationServo.write(MIDDLE+angle-sway);
            lwingServo.write(LWING_MIDDLE);
            delay(rest);
            
            
            rotationServo.write(MIDDLE+angle+sway);
            rwingServo.write(RWING_MIDDLE+sway);
            delay(rest);
            
            rotationServo.write(MIDDLE+angle-sway);
            lwingServo.write(LWING_MIDDLE-sway);
            delay(rest);
            
            
            rotationServo.write(MIDDLE+angle+sway);
            rwingServo.write(RWING_UP);
            delay(rest);
            
            rotationServo.write(MIDDLE+angle-sway);
            lwingServo.write(LWING_UP);
            delay(rest);
            
            
            rotationServo.write(MIDDLE+angle+sway);
            rwingServo.write(RWING_MIDDLE-sway);
            delay(rest);
            
            rotationServo.write(MIDDLE+angle-sway);
            lwingServo.write(LWING_MIDDLE+sway);
            delay(rest);
            
            
            rotationServo.write(MIDDLE+angle+sway);
            rwingServo.write(RWING_DOWN);
            delay(rest);
            
            rotationServo.write(MIDDLE+angle-sway);
            lwingServo.write(LWING_DOWN);
            delay(rest);
        }
        
        
        for(int i=0; i<5; i++) {
            rotationServo.write(MIDDLE+angle+(sway*2));
            delay(100);
            rotationServo.write(MIDDLE+angle-(sway*2));
            delay(100);
        }
        
        // turn
        
        turn++;
        
        if(turn%3 == 0) {
            left = !left;
            turn = 1;
        }
        
        if(left) {
            angle += 60;
        } else {
            angle -= 60;
        }
        
        rotationServo.write(MIDDLE+angle);
        
        rwingServo.write(RWING_UP);
        lwingServo.write(LWING_UP);
        
        delay(rest);
        
        rwingServo.write(RWING_MIDDLE);
        lwingServo.write(LWING_MIDDLE);
        
    }
    
}

// ---------------
// R O T A T I O N
// ---------------

void goLeft() {
    rotationServo.write(LEFT);
}

void goRight() {
    rotationServo.write(RIGHT);
}

void goMiddle() {
    rotationServo.write(MIDDLE);
}

void shakeNo() {
    
    for(int i=0; i<5; i++) {
        rotationServo.write(MIDDLE+20);
        delay(100);
        rotationServo.write(MIDDLE-20); 
        delay(100);
    }
    
    rotationServo.write(MIDDLE);
    
}

void shiver() {
    
    for(int i=0; i<5; i++) {
        rotationServo.write(MIDDLE+10);
        delay(80);
        rotationServo.write(MIDDLE-10); 
        delay(80);
    }
    
    rotationServo.write(MIDDLE);
    
}

void searching() {
    
    int curr = rotationServo.read();
    
    int lorr = (int)random(0, 2);
    int newpos = curr;
    
    if(lorr == 0) {
        newpos += (int)random(20, 60);
    } else {
        newpos -= (int)random(20, 60);
    }
    
    if(newpos > 180) newpos = 180; 
    if(newpos < 0) newpos = 0;
    
    rotationServo.write(newpos);
    
}

// ----------
// W I N G S
// ----------

void rwingWave() {
    
    for(int i=0; i<5; i++) {
        rwingServo.write(RWING_UP);
        delay(150);
        rwingServo.write(RWING_DOWN);
        delay(150);
    }
    
    rwingServo.write(RWING_MIDDLE);
    
}

void lwingWave() {
    
    for(int i=0; i<5; i++) {
        lwingServo.write(LWING_UP);
        delay(150);
        lwingServo.write(LWING_DOWN);
        delay(150);
    }
    
    lwingServo.write(LWING_MIDDLE);
    
}

void wingsWave() {
    
    for(int i=0; i<5; i++) {
        lwingServo.write(LWING_UP);
        rwingServo.write(RWING_UP);
        delay(150);
        lwingServo.write(LWING_DOWN);
        rwingServo.write(RWING_DOWN);
        delay(150);
    }
    
    lwingServo.write(LWING_MIDDLE);
    rwingServo.write(RWING_MIDDLE);
    
}

void rwingExcited() {
    
    for(int i=0; i<5; i++) {
        rwingServo.write(RWING_UP);
        delay(100);
        rwingServo.write(RWING_UP-30);
        delay(100);
    }
    
    rwingServo.write(RWING_MIDDLE);
    
}

void lwingExcited() {
    
    for(int i=0; i<5; i++) {
        lwingServo.write(LWING_UP);
        delay(100);
        lwingServo.write(LWING_UP+30);
        delay(100);
    }
    
    lwingServo.write(LWING_MIDDLE);
    
}

void wingsExcited() {
    
    for(int i=0; i<5; i++) {
        rwingServo.write(RWING_UP);
        lwingServo.write(LWING_UP);
        delay(100);
        rwingServo.write(RWING_UP-30);
        lwingServo.write(LWING_UP+30);
        delay(100);
    }
    
    rwingServo.write(RWING_MIDDLE);
    lwingServo.write(LWING_MIDDLE);
    
}

void rwingBottom() {
    
    for(int i=0; i<5; i++) {
        rwingServo.write(RWING_DOWN);
        delay(100);
        rwingServo.write(RWING_DOWN+30);
        delay(100);
    }
    
    rwingServo.write(RWING_MIDDLE);
    
}

void lwingBottom() {
    
    for(int i=0; i<5; i++) {
        lwingServo.write(LWING_DOWN);
        delay(100);
        lwingServo.write(LWING_DOWN-30);
        delay(100);
    }
    
    lwingServo.write(LWING_MIDDLE);
    
}

void wingsBottom() {
    
    for(int i=0; i<5; i++) {
        rwingServo.write(RWING_DOWN);
        lwingServo.write(LWING_DOWN);
        delay(100);
        rwingServo.write(RWING_DOWN+30);
        lwingServo.write(LWING_DOWN-30);
        delay(100);
    }
    
    rwingServo.write(RWING_MIDDLE);
    lwingServo.write(LWING_MIDDLE);
    
}


// ---------------
// P A R T Y ! ! !
// ---------------


void partyBehaviour() {
    
    playTone((int)random(20,175), (int)random(70, 150));
    updateLights();
    
}


// -------
// L D R s
// -------


void chaseBehaviour(int ldrL, int ldrR) {
    
    if(chase) {
    
        int current = rotationServo.read();
        
        if(ldrL < (ldrR+thresh) && ldrL > (ldrR-thresh)) {
            
            if(current < 90) {
                rotationServo.write(current+1);
            } else if(current > 90) {
                rotationServo.write(current-1);
            }
            
        } else if(ldrL > (ldrR+thresh)) {

            if(current < 180) {
                if(photovore) {
                    rotationServo.write(current-1);
                } else {
                    rotationServo.write(current+1);
                }
            } else {
                wingsExcited();
            }
            
        } else if(ldrL < (ldrR-thresh)) {

            if(current > 0) {
                if(photovore) {
                    rotationServo.write(current+1);
                } else {
                    rotationServo.write(current-1);
                }
            } else {
                wingsExcited();
            }
            
        }
        delay(10);
    }
}

void peekABooBehaviour(int ldrL, int ldrR) {
    
    if(ldrL <= (ldrLprev-50) || ldrR <= (ldrRprev-50)) {
        
        // Close eyes
        digitalWrite(RED, HIGH);
        digitalWrite(GREEN, HIGH);
        digitalWrite(BLUE, HIGH);
        
        // Wiggle the wings
        wingsExcited();
        
        // Open Eyes
        digitalWrite(RED, LOW);
        digitalWrite(GREEN, LOW);
        digitalWrite(BLUE, LOW);
        
        // Play music
        for(int i=0; i<3; i++) {
            playTone((int)random(100,200), (int)random(50, 200));
            delay(50);
        }
        
    }
    
    ldrLprev = ldrL;
    ldrRprev = ldrR;
    
}


// --------------
// S P E A K E R
// --------------

void randomChirp() {
    for(int i=0; i<10; i++) {
        playTone((int)random(100,800), (int)random(50, 200));
    }
}

void playTone(int tone, int duration) {
	
	for (long i = 0; i < duration * 1000L; i += tone * 2) {
		digitalWrite(SPKR, HIGH);
		delayMicroseconds(tone);
		digitalWrite(SPKR, LOW);
		delayMicroseconds(tone);
	}
	
}


// ---------------
// L E D   F A D E
// ---------------


void rainbowFade() {
    
    int dim = 5; // usually 15
    
    // Main loop for the fading. All the LEDs start
    // off at dim (15), and end at dim... they never
    // go completely off since it is easier to make
    // the colours fade in and out
    // You can probably adjust the i+=1 for a faster 
    // fading rate
    for(fadeCount=15; fadeCount<=255; fadeCount+=1) { 
        
        // For fading the rainbow, it cycles from 
        // red to blue then to white and repeat
        if(fadingRainbow) {
            
            // Red: 0,1,5,6
            if(fadeColour == 0 || fadeColour == 1 || fadeColour == 5 || fadeColour == 6) {
                analogWrite(RED, fadeCount);
            } else {
                analogWrite(RED, dim);
            }
            
            // Green: 1,2,3,6
            if(fadeColour == 1 || fadeColour == 2 || fadeColour == 3 || fadeColour == 6) {
                analogWrite(GREEN, fadeCount);
            } else {
                analogWrite(GREEN, dim);
            }
            
            // Blue: 3,4,5,6
            if(fadeColour == 3 || fadeColour == 4 || fadeColour == 5 || fadeColour == 6) {
                analogWrite(BLUE, fadeCount);
            } else {
                analogWrite(BLUE, dim);
            }
            
            // Or you can just do classic white
        } else {
            
            analogWrite(RED, fadeCount);
            analogWrite(GREEN, fadeCount);
            analogWrite(BLUE, fadeCount);
            
        }
        
        // Here's the hardcoded part that does the
        // specific delays for the specific times
        if (fadeCount > 150) delay(4);
        if ((fadeCount > 125) && (fadeCount < 151)) delay(5);
        if ((fadeCount > 100) && (fadeCount < 126)) delay(7);
        if ((fadeCount > 75) && (fadeCount < 101)) delay(10);
        if ((fadeCount > 50) && (fadeCount < 76)) delay(14);
        if ((fadeCount > 25) && (fadeCount < 51)) delay(18);
        if ((fadeCount > 1) && (fadeCount < 26)) delay(19);
    }
    
    for(fadeCount=255; fadeCount>=15; fadeCount-=1) {
        
        if(fadingRainbow) {
            
            // Red: 0,1,5,6
            if(fadeColour == 0 || fadeColour == 1 || fadeColour == 5 || fadeColour == 6) {
                analogWrite(RED, fadeCount);
            } else {
                analogWrite(RED, dim);
            }
            
            // Green: 1,2,3,6
            if(fadeColour == 1 || fadeColour == 2 || fadeColour == 3 || fadeColour == 6) {
                analogWrite(GREEN, fadeCount);
            } else {
                analogWrite(GREEN, dim);
            }
            
            // Blue: 3,4,5,6
            if(fadeColour == 3 || fadeColour == 4 || fadeColour == 5 || fadeColour == 6) {
                analogWrite(BLUE, fadeCount);
            } else {
                analogWrite(BLUE, dim);
            }
            
        } else {
            
            analogWrite(RED, fadeCount);
            analogWrite(GREEN, fadeCount);
            analogWrite(BLUE, fadeCount);
            
        }
        
        if (fadeCount > 150) delay(4);
        if ((fadeCount > 125) && (fadeCount < 151)) delay(5);
        if ((fadeCount > 100) && (fadeCount < 126)) delay(7);
        if ((fadeCount > 75) && (fadeCount < 101)) delay(10);
        if ((fadeCount > 50) && (fadeCount < 76)) delay(14);
        if ((fadeCount > 25) && (fadeCount < 51)) delay(18);
        if ((fadeCount > 1) && (fadeCount < 26)) delay(19);
    }
    
    fadeColour++;
    if(fadeColour == 7) fadeColour=0;
    
    delay(970);
    
}


void updateLights() {
    
    int dim = 5; // Usually 50
    
    ledR = int(random(5, 255));
    ledG = int(random(5, 255));
    ledB = int(random(5, 255));
	
	fade( ledR_0,    ledG_0,      ledB_0, // Start
		  ledR,        ledG,        ledB,  // Finish
          1);
	
    ledR_0 = ledR;
    ledG_0 = ledG;
    ledB_0 = ledB;
    
}


void fade( int start_R,  int start_G,  int start_B, 
		   int finish_R, int finish_G, int finish_B,
		   int stepTime ) {
    
    int skipEvery_R = 256/abs(start_R-finish_R); 
    int skipEvery_G = 256/abs(start_G-finish_G);
    int skipEvery_B = 256/abs(start_B-finish_B);
    
    for(int i=0; i<256; i++) {
        
        if(start_R<finish_R) {
            if(i<=finish_R) {
                if(i%skipEvery_R == 0) {
                    analogWrite(RED, i);
                } 
            }
        } else if(start_R>finish_R) {
            if(i>=(256-start_R)) {
                if(i%skipEvery_R == 0) {
                    analogWrite(RED, 256-i); 
                }
            } 
        }
        
        if(start_G<finish_G) {
            if(i<=finish_G) {
                if(i%skipEvery_G == 0) {
                    analogWrite(GREEN, i);
                } 
            }
        } else if(start_G>finish_G) {
            if(i>=(256-start_G)) {
                if(i%skipEvery_G == 0) {
                    analogWrite(GREEN, 256-i); 
                }
            } 
        }
        
        if(start_B<finish_B) {
            if(i<=finish_B) {
                if(i%skipEvery_B == 0) {
                    analogWrite(BLUE, i);
                } 
            }
        } else if(start_B>finish_B) {
            if(i>=(256-start_B)) {
                if(i%skipEvery_B == 0) {
                    analogWrite(BLUE, 256-i); 
                }
            } 
        }
                
        delay(stepTime);
        
    }
    
}



// ----------------------
// C A L I B R A T I O N
// ----------------------


void beakCalibration() {
    
    if(Serial.available() > 0) {
        c = Serial.read();
        
        if(c == 's') {
            Serial << "Stop position: " << pos << endl;
            stopped = true;
        }
        
        if(c == 'g') {
            forwards = !forwards;
            stopped = false;
        }
        
    }
    
    if(!stopped) {
        if(forwards) {
            pos += 1;
        } else {
            pos -= 1;
        }
        beakServo.write(pos);
        Serial << pos << endl;
        delay(100);
        
        if(pos == 30 || pos == 75) {
            forwards = !forwards;
        }
        
    }
    
}

void rwingCalibration() {
    
    if(Serial.available() > 0) {
        c = Serial.read();
        
        if(c == 's') {
            Serial << "Stop position: " << pos << endl;
            stopped = true;
        }
        
        if(c == 'g') {
            forwards = !forwards;
            stopped = false;
        }
        
    }
    
    if(!stopped) {
        if(forwards) {
            pos += 1;
        } else {
            pos -= 1;
        }
        rwingServo.write(pos);
        Serial << pos << endl;
        delay(100);
        
        if(pos == RWING_UP || pos == RWING_DOWN) {
            forwards = !forwards;
        }
        
    }
    
}

void lwingCalibration() {
    
    if(Serial.available() > 0) {
        c = Serial.read();
        
        if(c == 's') {
            Serial << "Stop position: " << pos << endl;
            stopped = true;
        }
        
        if(c == 'g') {
            forwards = !forwards;
            stopped = false;
        }
        
    }
    
    if(!stopped) {
        if(forwards) {
            pos += 1;
        } else {
            pos -= 1;
        }
        lwingServo.write(pos);
        Serial << pos << endl;
        delay(100);
        
        if(pos == LWING_UP || pos == LWING_DOWN) {
            forwards = !forwards;
        }
        
    }
    
}



// -------------
// T E S T I N G
// -------------


void beakTest() {
    
    beakServo.write(BEAK_OPEN);
    delay(2000);
    beakServo.write(BEAK_CLOSED);
    delay(2000);
    
}

void rwingTest() {
    
    rwingServo.write(RWING_UP);
    delay(2000);
    rwingServo.write(RWING_DOWN);
    delay(2000);
    
}

void lwingTest() {
    
    lwingServo.write(LWING_UP);
    delay(2000);
    lwingServo.write(LWING_DOWN);
    delay(2000);
    
}

void rotationTest() {
    
    rotationServo.write(LEFT);
    delay(2000);
    rotationServo.write(RIGHT);
    delay(2000);
    
}

void hulaTest() {
    
    for(int i=0; i<3; i++) {
        digitalWrite(HULA, HIGH);
        delay(5);
        digitalWrite(HULA, LOW);
        delay(100);
    }
    delay(1000);
    
}

void ldrTest() {
    
    Serial << "R: " << analogRead(LDR_R) << " L: " << analogRead(LDR_L) << endl;
    delay(100);
    
}

void ledTest() {
    
    Serial << "Red" << endl;
    digitalWrite(RED, LOW);
    digitalWrite(GREEN, HIGH);
    digitalWrite(BLUE, HIGH);
    delay(2000);
    
    Serial << "Green" << endl;
    digitalWrite(RED, HIGH);
    digitalWrite(GREEN, LOW);
    digitalWrite(BLUE, HIGH);
    delay(2000);
    
    Serial << "Blue" << endl;
    digitalWrite(RED, HIGH);
    digitalWrite(GREEN, HIGH);
    digitalWrite(BLUE, LOW);
    delay(2000);
    
}

