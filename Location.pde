class Location implements Comparable {
  PVector location, next_location;
  String mac, string_lasttime, status;
  long lasttime;
  float confidence_factor;
  Location() {
    location = new PVector();
  }
  public int compareTo(Object obj) {
    Location that = (Location)obj;
    return this.lasttime < that.lasttime ? -1 : this.lasttime == that.lasttime ? 0 : 1;
  }
}

