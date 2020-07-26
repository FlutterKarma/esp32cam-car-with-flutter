#ifndef ESP32_L298N_h
#define ESP32_L298N_h

#include "Arduino.h"

class ESP32_L298N
{
  public:
    ESP32_L298N(int pin1, int pin2, int ch1=0, int ch2=1, bool is_pwm=false);
    void drive(float speed);
    void drive(float speed, int duration);
    void brake();
    void standby();
    void test(float speed=1.0, int delay_milisec=500);
    void forward();
   void  backward();
  private:
    int pin1_, pin2_;  // A4, A5, A19, A18, A17, A16, A15, A14, A13, A10, A12, A11
    int ch1_, ch2_;    // 0~15
    bool is_pwm_;
    int speed_limit(int i_speed, int minmax=255);
    void fwd(int i_speed);
    void rev(int i_speed);
};

#endif
