/*
 Impy RoboBrrd
 --------------
 
 Nov 14, 2011
 robotgrrl.com
 
 Examples of how you can program your RoboBrrd!
 
 Licensed under the BSD 3-Clause license:
 http://www.opensource.org/licenses/BSD-3-Clause
 (see bottom for longer disclaimer)
 
 */

#include <Servo.h> 
#include <Streaming.h>
#include <PN532.h>

#define SCK 13
#define MOSI 11
#define SS 10
#define MISO 12

PN532 nfc(SCK, MISO, MOSI, SS);

Servo beakServo, rwingServo, lwingServo, rotationServo;

// Servos
int BEAK = 9;
int RWING = 8;
int LWING = 7;
int ROTATION = 6;
int HULA = 4;

// LEDs
int RED = A5;
int GREEN = A4;
int BLUE = A3;

// Misc
int SPKR = 5;
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

int hat = 0;
int step = 0;

int ldrL_home;
int ldrR_home;
int ldr_thresh = 30;

unsigned long photovorePlay = 10000;
unsigned long photovoreTimeStarted = 0;

void setup()  {
    
    Serial.begin(9600);
    
    Serial.println("Hello!");
    
    nfc.begin();
    
    uint32_t versiondata = nfc.getFirmwareVersion();
    if (! versiondata) {
        Serial.print("Didn't find PN53x board");
        while (1); // halt
    }
    // Got ok data, print it out!
    Serial.print("Found chip PN5"); Serial.println((versiondata>>24) & 0xFF, HEX); 
    Serial.print("Firmware ver. "); Serial.print((versiondata>>16) & 0xFF, DEC); 
    Serial.print('.'); Serial.println((versiondata>>8) & 0xFF, DEC);
    Serial.print("Supports "); Serial.println(versiondata & 0xFF, HEX);
    
    // configure board to read RFID tags and cards
    nfc.SAMConfig();
    
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
    
    // Evaluate LDRs
    evaluateLDRs();
    
    // Random chirp!
    randomChirp();
    
} 


void loop() { 
    
    checkNFC();
    
    switch (hat) {
        case 0:
            eyesWhite();
            break;
        case 1: // top hat
            
            photovore = true;
            photovoreCheck();
            
            switch (step) {
                case 0:
                    for(int i=0; i<3; i++) {
                        eyesWhite();
                        delay(100);
                        eyesBlue();
                        delay(100);
                    }
                    break;
                case 1:
                    beakServo.write(BEAK_OPEN);
                    for(int i=0; i<5; i++) {
                        playTone(260, 70);
                        playTone(280, 70);
                        playTone(300, 70);
                        delay(100);
                    }
                    beakServo.write(BEAK_CLOSED);
                    delay(300);
                    break;
                case 2:
                    rwingWave();
                    break;
                case 3:
                    beakServo.write(BEAK_OPEN);
                    for(int i=0; i<5; i++) {
                        playTone(80, 70);
                        playTone(100, 70);
                        playTone(120, 70);
                        delay(100);
                    }
                    beakServo.write(BEAK_CLOSED);
                    delay(300);
                    break;
                case 4:
                    lwingWave();
                    break;
                case 5:
                    beakServo.write(BEAK_OPEN);
                    for(int i=0; i<5; i++) {
                        playTone(160, 70);
                        playTone(180, 70);
                        playTone(200, 70);
                        delay(100);
                    }
                    beakServo.write(BEAK_CLOSED);
                    delay(300);
                    break;
                default:
                    break;
            }
            
            step++;
            if(step > 5) step = 0; 
            
            break;
        case 2: // red maker hat
            
            photovore = false;
            photovoreCheck();
            
            switch (step) {
                case 0:
                    for(int i=0; i<3; i++) {
                        eyesWhite();
                        delay(100);
                        eyesRed();
                        delay(100);
                    }
                    break;
                case 1:
                    wingsExcited();
                    break;
                case 2:
                    for(int i=0; i<3; i++) {
                        beakServo.write(BEAK_OPEN);
                        delay(300);
                        beakServo.write(BEAK_CLOSED);
                        delay(300);
                    }
                    break;
                case 3:
                    beakServo.write(BEAK_OPEN);
                    for(int i=0; i<5; i++) {
                        playTone(200, 70);
                        playTone(300, 140);
                        playTone(100, 70);
                        delay(100);
                    }
                    beakServo.write(BEAK_CLOSED);
                    delay(300);
                    break;
                case 4:
                    for(int i=0; i<2; i++) {
                        rotationServo.write(MIDDLE+10);
                        delay(200);
                        rotationServo.write(MIDDLE-10); 
                        delay(200);
                    }
                    
                    rotationServo.write(MIDDLE);
                    break;
                case 5:
                    rwingWave();
                    break;
                default:
                    break;
            }
            
            step++;
            if(step > 5) step = 0;
            
            break;
        case 3: // purple robot hat
            
            photovore = true;
            photovoreCheck();
            
            switch (step) {
                case 0:
                    for(int i=0; i<3; i++) {
                        eyesWhite();
                        delay(100);
                        eyesPurple();
                        delay(100);
                    }
                    break;
                case 1:
                    beakServo.write(BEAK_OPEN);
                    for(int i=0; i<5; i++) {
                        playTone(150, 100);
                        playTone(100, 70);
                        playTone(200, 80);
                        playTone(300, 70);
                        delay(100);
                    }
                    beakServo.write(BEAK_CLOSED);
                    delay(300);
                    break;
                case 2:
                    wingsExcited();
                    break;
                case 3:
                    for(int i=0; i<2; i++) {
                        rotationServo.write(MIDDLE+40);
                        delay(300);
                        rotationServo.write(MIDDLE-40); 
                        delay(300);
                    }
                    
                    rotationServo.write(MIDDLE);
                    break;
                case 4:
                    for(int i=0; i<5; i++) {
                        digitalWrite(HULA, HIGH);
                        delay(5);
                        digitalWrite(HULA, LOW);
                        delay(100);
                    }
                    break;
                case 5:
                    beakServo.write(BEAK_OPEN);
                    delay(300);
                    beakServo.write(BEAK_CLOSED);
                    delay(300);
                    beakServo.write(BEAK_OPEN);
                    delay(300);
                    beakServo.write(BEAK_MIDDLE);
                    delay(300);
                    beakServo.write(BEAK_OPEN);
                    delay(300);
                    beakServo.write(BEAK_CLOSED);
                    delay(300);
                    break;
                    
                default:
                    break;
            }
            
            step++;
            if(step > 5) step = 0;
            
            break;
        case 4: // green hat
            
            switch (step) {
                case 0:
                    for(int i=0; i<3; i++) {
                        eyesWhite();
                        delay(100);
                        eyesGreen();
                        delay(100);
                    }
                    break;
                case 1:
                    beakServo.write(BEAK_OPEN);
                    for(int i=0; i<3; i++) {
                        playTone(80, 100);
                        playTone(60, 70);
                        playTone(30, 80);
                        delay(100);
                    }
                    beakServo.write(BEAK_CLOSED);
                    delay(300);
                    break;
                case 2:
                    for(int i=0; i<5; i++) {
                        rotationServo.write(MIDDLE+60);
                        delay(300);
                        rotationServo.write(MIDDLE-60); 
                        delay(300);
                    }
                    
                    rotationServo.write(MIDDLE);
                    break;
                case 3:
                    for(int i=0; i<5; i++) {
                        rotationServo.write(MIDDLE+40);
                        delay(100);
                        rotationServo.write(MIDDLE-40); 
                        delay(100);
                    }
                    
                    rotationServo.write(MIDDLE);
                    break;
                case 4:
                    for(int i=0; i<5; i++) {
                        rotationServo.write(MIDDLE+60);
                        delay(300);
                        rotationServo.write(MIDDLE-60); 
                        delay(300);
                    }
                    
                    rotationServo.write(MIDDLE);
                    break;
                case 5:
                    for(int i=0; i<5; i++) {
                        rotationServo.write(MIDDLE+40);
                        delay(100);
                        rotationServo.write(MIDDLE-40); 
                        delay(100);
                    }
                    
                    rotationServo.write(MIDDLE);
                    break;
                    
                default:
                    break;
            }
            
            step++;
            if(step > 5) step = 0;
            
            break;
        default:
            break;
    }
    
}

void checkNFC() {
    
    uint32_t id;
    // look for MiFare type cards
    id = nfc.readPassiveTargetID(PN532_MIFARE_ISO14443A);
    
    if (id != 0) {
        
        uint8_t keys[]= {0xFF,0xFF,0xFF,0xFF,0xFF,0xFF};
        if(nfc.authenticateBlock(1, id ,0x08,KEY_A,keys)) //authenticate block 0x08
        {
            //if authentication successful
            uint8_t block[16];
            //read memory block 0x08
            if(nfc.readMemoryBlock(1,0x08,block)) {
                //if read operation is successful
                
                if(block[0] == 1) {
                    //Serial.println("top hat");
                    hat = 1;
                } else if(block[0] == 2) {
                    //Serial.println("red maker hat");
                    hat = 2;
                } else if(block[0] == 3) {
                    //Serial.println("purple robot hat");
                    hat = 3;
                } else if(block[0] == 4) {
                    //Serial.println("green hat");
                    hat = 4;
                }
                
            }
        }
    } else {
        //Serial.println("no hat");
        hat = 0;
        step = 0;
    }
    
}

void photovoreCheck() {
    
    int ldrL_0 = analogRead(LDR_L);
    int ldrR_0 = analogRead(LDR_R);
    
    //Serial << "L Difference: " << (ldrL_home-ldrL_0) << endl;
    //Serial << "R Difference: " << (ldrR_home-ldrR_0) << endl;
    
    if(ldrL_0 < (ldrL_home-ldr_thresh) && ldrR_0 < (ldrR_home-ldr_thresh)) {
        Serial << "L & R is covered!" << endl;
        chase = true;
        
        photovoreTimeStarted = millis();
        
        Serial << "result = " << photovoreTimeStarted << "-" << millis() << "=" << millis()-photovoreTimeStarted << endl;
        
        while(millis()-photovoreTimeStarted <= photovorePlay) {
            
            checkNFC();
            if(hat == 0) break;
            
            Serial << "chasing!";
            chaseBehaviour(analogRead(LDR_L), analogRead(LDR_R));
        }
     
        chase = false;
        photovoreTimeStarted = 0;
        goMiddle();
        
    }
    
}

void eyesBlue() {
    digitalWrite(RED, HIGH);
    digitalWrite(GREEN, HIGH);
    digitalWrite(BLUE, LOW);
}

void eyesRed() {
    digitalWrite(RED, LOW);
    digitalWrite(GREEN, HIGH);
    digitalWrite(BLUE, HIGH);
}

void eyesPurple() {
    digitalWrite(RED, LOW);
    digitalWrite(GREEN, HIGH);
    digitalWrite(BLUE, LOW);
}

void eyesGreen() {
    digitalWrite(RED, HIGH);
    digitalWrite(GREEN, LOW);
    digitalWrite(BLUE, HIGH);
}

void eyesWhite() {
    digitalWrite(RED, LOW);
    digitalWrite(GREEN, LOW);
    digitalWrite(BLUE, LOW);
}

void eyesOff() {
    digitalWrite(RED, HIGH);
    digitalWrite(GREEN, HIGH);
    digitalWrite(BLUE, HIGH);
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

void updateLights() {
    // TODO.
}


// -------
// L D R s
// -------


void evaluateLDRs() {
    
    int ldrL_total = 0;
    int ldrR_total = 0;
    
    for(int i=0; i<10; i++) {
        ldrL_total += analogRead(LDR_L);
        ldrR_total += analogRead(LDR_R);
        delay(100);
    }
    
    Serial << "LDR Total- L: " << ldrL_total << " R: " << ldrR_total << endl;
    
    ldrL_home = (int)ldrL_total/10;
    ldrR_home = (int)ldrR_total/10;
    
    Serial << "LDR Home- L: " << ldrL_home << " R: " << ldrR_home << endl;
    
}

void chaseBehaviour(int ldrL, int ldrR) {
    
    int d = 5;
    
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
                    rotationServo.write(current-d);
                } else {
                    rotationServo.write(current+d);
                }
            } else {
                wingsExcited();
            }
            
        } else if(ldrL < (ldrR-thresh)) {

            if(current > 0) {
                if(photovore) {
                    rotationServo.write(current+d);
                } else {
                    rotationServo.write(current-d);
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


/*

Copyright (c) 2011, RobotGrrl.com
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list 
of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this 
list of conditions and the following disclaimer in the documentation and/or 
other materials provided with the distribution.
Neither the name of the RobotGrrl.com nor the names of its contributors may be 
used to endorse or promote products derived from this software without specific 
prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON 
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/
