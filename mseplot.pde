import java.util.Calendar;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.ParseException;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

final String filenames[] = {
  "history_01.xml", "history_02.xml", "history_03.xml", "history_04.xml", "history_05.xml", "history_06.xml", "history_07.xml", "history_08.xml", "history_09.xml", "history_10.xml", "history_11.xml", "history_12.xml", "history_13.xml", "history_14.xml", "history_15.xml", "history_16.xml", "history_17.xml", "history_18.xml", "history_19.xml", "history_20.xml",
};
int nloc, nloc_min;
ArrayList<Location> locations;
HashMap<String,Client> clients;
long time_min, time_max;
final long time_tic = 60 * 1000;
final long timeoffset = -4 * 3600; // time of data is 4 hours ahead without timezone.
SimpleDateFormat xmldate, outdate;
PImage mapimg;
final float mapimgw = 1271, mapimgh = 733;
final int winw = 800, winh = 450;
final float mapw = 351.6, maph = 199.1;
final float mapscale = mapimgw/mapw;
final float confidence_threshold = 60;

void setup() {
  size(winw, winh);
  textFont(createFont("Arial", 32, true));
  Locale.setDefault(Locale.US);
  locations = new ArrayList<Location>();
  clients = new HashMap<String,Client>();
  xmldate = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");
  outdate = new SimpleDateFormat("yyyy-MM-dd HH:mm a");
  Calendar calendar = Calendar.getInstance();
  nloc = 0;
  time_min = (long)2e12;
  time_max = 0;
  for (int i = 0; i < filenames.length; i++) {
    XML xml = loadXML(filenames[i]);
    for (XML xml_location : xml.getChildren()) {
      XML xml_mapcood = xml_location.getChild("MapCoordinate");
      XML xml_stat = xml_location.getChild("Statistics");
      Location location = new Location();
      locations.add(location);
      location.mac = xml_location.getString("macAddress");
      location.status = xml_location.getString("dot11Status");
      location.location.set(xml_mapcood.getFloat("x"), xml_mapcood.getFloat("y"));
      location.confidence_factor = xml_location.getFloat("confidenceFactor");
      try {
        location.string_lasttime = xml_stat.getString("lastLocatedTime");
        calendar.setTime(xmldate.parse(location.string_lasttime));
        location.lasttime = calendar.getTimeInMillis() + timeoffset;
        if (location.lasttime < time_min) {
          time_min = location.lasttime;
        } else if (time_max < location.lasttime) {
          time_max = location.lasttime;
        }
      } catch (ParseException e) {
        println("parse error " + xml_stat.getString("lastLocatedTime"));
      }
      if (clients.get(location.mac) == null) {
        clients.put(location.mac, new Client(location.mac));
      }
      nloc++;
    }
    frameRate(30);
  }
  println("location count = " + nloc);
  println("mac address count = " + clients.size());
  println("time from " + time_min + " to " + time_max + ", range " + (time_max-time_min));
  mapimg = loadImage("2F.jpg");
  Collections.sort(locations);
  nloc_min = 0;
  Location location = locations.get(nloc_min);
  time_min = 1378738800000l;//+86400000l*3;
  time_max = 1379034001000l;
  while (location.lasttime < time_min - 100) {
    location = locations.get(++nloc_min);
  }
}

void draw() {
  background(255);
  scale(winw/mapimgw);
  image(mapimg, 0, 0);
  long hour = (time_min/3600+9000)%24000;
  if (hour < 5000 || 19000 < hour) {
    fill(0, 100);
  } else if (hour < 7000) {
    fill(0, (7000-hour) / 20);
  } else if (hour < 17000) {
    fill(0, 0);
  } else {
    fill(0, (hour - 17000) / 20);
  }
  rect(0, 0, mapimgw, mapimgh);
  fill(0);
  text(outdate.format(time_min-time_min%600000), 10, 36);
  scale(mapscale);
  fill(128, 50);
  noStroke();
  for (time_min += time_tic; nloc_min < nloc; nloc_min++) {
    Location location = locations.get(nloc_min);
    if (time_min < location.lasttime) break;
    //if (confidence_threshold < location.confidence_factor) continue;
    Client client = clients.get(location.mac);
    client.target.set(location.location);
    if (client.falpha <= Client.alpha_min) {
      client.current.set(location.location);
    }
    client.falpha = Client.alpha_max;
    //client.fcolor = (confidence_threshold < location.confidence_factor) ? client.mycolor : client.probing; 
    if (client.fcolor != client.mycolor) {
      client.fcolor = location.status.equals("PROBING") ? client.probing : client.associated;
    }
  }
  for (Client client : clients.values()) {
    if (Client.alpha_min < client.falpha) {
      noStroke();
      fill(client.fcolor, client.falpha);
      ellipse(client.current.x, client.current.y, 5, 5);
      client.lerp(0.2);
      //client.lerp(1);
    }
  }
  if (time_max < time_min) {
    noLoop();
  }
  //saveFrame();
}

