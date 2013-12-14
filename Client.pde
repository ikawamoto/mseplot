final String my_macs[] = {
  "00:11:22:ee:44:55",
};

class Client {
  static final int alpha_min = 10, alpha_max = 100;
  final color associated = color(16, 64, 128), mycolor = color(255, 32, 32), probing = color(96);
  PVector current, target;
  color fcolor, scolor;
  float falpha, salpha;
  Client(String mac) {
    current = new PVector();
    target = new PVector();
    fcolor = associated;
    for (String my_mac : my_macs) {
      if (mac.equals(my_mac)) fcolor = mycolor;
    }
    falpha = 0;
    scolor = fcolor;
    salpha = 0;
  }
  void lerp(float amt) {
    falpha -= (alpha_max - alpha_min) / 30;
    current.lerp(target, amt);
  }
  void lerp() {
    //lerp(PVector.sub(current, target).mag() / 300 + 0.1);
    lerp(0.2);
  }
}

