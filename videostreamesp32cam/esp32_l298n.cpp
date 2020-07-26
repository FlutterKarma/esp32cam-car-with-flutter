#include "esp32_l298n.h"

ESP32_L298N::ESP32_L298N(int pin1, int pin2, int ch1, int ch2, bool is_pwm)
{
  pin1_ = pin1;
  pin2_ = pin2;
  ch1_ = ch1;
  ch2_ = ch2;
  is_pwm_ = is_pwm;

  pinMode(pin1_, OUTPUT);
  pinMode(pin2_, OUTPUT);

  if(is_pwm_){
    ledcSetup(ch1_, 12800, 8);  // 8bit = 256
    ledcSetup(ch2_, 12800, 8);
    ledcAttachPin(pin1_, ch1_);
    ledcAttachPin(pin2_, ch2_);
  }
}

int ESP32_L298N::speed_limit(int i_speed, int minmax)
{
  if (i_speed>=minmax)
    return minmax;
  else if (i_speed<=-minmax)
    return -minmax;
  else
    return i_speed;
}

void ESP32_L298N::drive(float speed)
{
  int i_speed = speed_limit(int(speed * 255));
  if (i_speed>=0) fwd(i_speed);
  else rev(-i_speed);
}

void ESP32_L298N::drive(float speed, int duration)
{
  drive(speed);
  delay(duration);
}

void ESP32_L298N::fwd(int i_speed)
{
  if(is_pwm_){
    ledcWrite(ch1_, i_speed);
    ledcWrite(ch2_, 0);
  }else{
    digitalWrite(pin1_, HIGH);
    digitalWrite(pin2_, LOW);
  }
}

void ESP32_L298N::rev(int i_speed)
{
  if(is_pwm_){
    ledcWrite(ch1_, 0);
    ledcWrite(ch2_, i_speed);
  }else{
    digitalWrite(pin1_, LOW);
    digitalWrite(pin2_, HIGH);
  }
}

void ESP32_L298N::brake()
{
  if(is_pwm_){
    ledcWrite(ch1_, 255);
    ledcWrite(ch2_, 255);
  }else{
    digitalWrite(pin1_, HIGH);
    digitalWrite(pin2_, HIGH);
  }
}

void ESP32_L298N::standby()
{
  if(is_pwm_){
    ledcWrite(ch1_, 0);
    ledcWrite(ch2_, 0);
  }else{
    digitalWrite(pin1_, LOW);
    digitalWrite(pin2_, LOW);
  }
}

void ESP32_L298N::test(float speed, int delay_milisec)
{
  drive(speed);
  delay(delay_milisec);
  drive(-speed);
  delay(delay_milisec);
  brake();
}

void ESP32_L298N::forward()
{
  fwd(1);
  delay(50);

}

void ESP32_L298N::backward()
{
  
  rev(1);
  delay(50);
 }
