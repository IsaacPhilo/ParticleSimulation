import java.awt.Color;
import java.awt.Graphics;
import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Scanner;



void setup(){
  size(800,1000);
  frameRate(200);
  
  int numEach = 100;
  int desiredTypeNumber = 3;
  for(int i = 0; i < desiredTypeNumber; i++){
    for(int j = 0; j <numEach; j++){
      new Particle(i);
    }
  }
  allParticles.remove(0);
  //These type repulsions are the defaults given by https://hunar4321.github.io/particle-life/particle_life.html#91651088029
  //specifyTypeRepulsions(new double[][]{{0.9261392140761018, -0.8341653244569898, 0.2809289274737239, -0.06427307985723019}, {-0.46170964650809765, 0.49142434634268284, 0.2760726027190685, 0.6413487386889756}, {-0.7874764292500913, 0.234, -0.024112331215292215, -0.7487592226825655}, {0.5655814143829048, 0.9484694371931255, -0.36052887327969074, 0.4411409106105566}});
  //new Particle(0);
  //new Particle(1);
  
  //Particle.specifyTypeRepulsions(new double[][]{{-4,4},{4,-4}});
  //specifyTypeRepulsions(formattedStringToRepulsions("[[-0.6768578025689962, 0.6048228707281564, -0.2837894894224675, 0.1794840595201701], [0.07828455099118026, 6.26080318497424E-4, 0.5007899239400981, -0.30617193252315467], [0.16257597242912403, -0.3334213753533426, -0.34501937340755195, -0.019786778565958896], [0.987919669174701, -0.6601396752943862, -0.22285354475343944, 0.08998201083435609]]"));
  double factor = 5;
  randomizeTypeRepulsions(desiredTypeNumber, factor);
  System.out.println(getRepulsions());
  randomizeColors(desiredTypeNumber);
  
}
void draw(){
  background(Color.BLACK.getRGB());
  for(Particle p: allParticles){
    fill(allColors.get(p.getType()).getRGB());
    circle((int)p.getX(), (int)p.getY(), p.getSize());
  }
  Particle.updateAll();
}

  private int size;
  private double x, y;
  public static final int DEFAULT_SIZE = 10;
  private int type;
  public static final int DEFAULT_TYPE = 0;
  private double vx;
  private double vy;
  
  private static int WIDTH = 750;
  private static int HEIGHT = 900;
  private static double LOSS_FACTOR = 0.5;//DON'T SET TO 1 OR ABOVE
  
  private static ArrayList<ArrayList<Double>> repulsions = new ArrayList<>();//for every added particle type, there is a new relationship between that type and all other types. Technically, all forces should be met with equal and opposite forces in the other direction, but we don't HAVE to do that here if we don't want to
  public static final double DEFAULT_REPULSION = 2;
  private static int numTypes = 0;
  private static List<Integer> types = new ArrayList<>();
  
  public static final double WALL_REPULSION = 3;
  
  public static boolean directInverse = true;
  public static boolean invertForces = true;
  public static boolean printOnIteration = false;
  public static boolean printVelocities = false;
  
  public static boolean firstParticle = true;//Eliminating weird extra particles
  {if(firstParticle){allParticles = new ArrayList<Particle>();firstParticle=false;}}
  
  public static ArrayList<ArrayList<Double>> getRepulsions(){
    return repulsions;
  }
  
  private static ArrayList<Particle> allParticles = new ArrayList<>();
  private static Map<Integer, Color> allColors = new HashMap<>();
    
  public static int random() {
    return (int)(Math.random()*HEIGHT);//so that Math.random's pseudorandom number isn't always the same
  }
  
  public Particle() {
    this(DEFAULT_SIZE, random(), random(), DEFAULT_TYPE);
  }
  public Particle(int size, int x, int y, int type) {
    this(size, x, y, type, 0, 0);
  }
  public Particle(int size, int x, int y, int type, int vx, int vy) {
    this.size = size;
    this.x = x;
    this.y = y;
    this.type = type;
    this.vx = vx;
    this.vy = vy;
    allParticles.add(this);
    if(!types.contains(type)) {
      types.add(type);
      numTypes++;
      repulsions.add(new ArrayList<Double>());
    }
  }
  public Particle(int type){
    this(DEFAULT_SIZE, random(), random(), type);
  }
  
  public void drawOne() {
    //ellipse((int)x, (int)y, size, size);//If we cast the values here, we can increment them by small amounts elsewhere and only display the change when it has accumulated beyond the ones place
  }
  
  public void updateVelocity() {
    for(Particle p: allParticles) {
      if(!p.equals(this)) {
        double angle = getAngle(this, p);
        double force = forceDistProportion(this, p);
        vx += getXComponent(force, angle);
        vy += getYComponent(force, angle);
        
        if(printVelocities) {
          System.out.println("xComponent: " + getXComponent(force, angle) + "\n" + "yComponent: " + getYComponent(force, angle));
          System.out.println("Velocities (X,Y): (" + vx + "," + vy + ")");
        }
      }
      double lDist = getX();
      double rDist = WIDTH-getX();
      double tDist = getY();
      double bDist = HEIGHT-getY();
      vx += WALL_REPULSION/lDist;
      vx -= WALL_REPULSION/rDist;
      vy += WALL_REPULSION/tDist;
      vy -= WALL_REPULSION/bDist;
    }
  }
  
  public static double dist(Particle p1, Particle p2) {
    return Math.sqrt(Math.pow(p2.getX()-p1.getX(), 2) + Math.pow(p2.getY()-p1.getY(), 2));
  }
  
  public static double distProportion(Particle p1, Particle p2) {//for specifying and using the proportionality of distance to the "gravitational" or "anitgravitational" force
    if(directInverse) {
      return 1.0/dist(p1,p2);
    }
    else {
      return 1.0/(dist(p1,p2)*dist(p1,p2));
    }
  }
  
  public static double forceDistProportion(Particle p1, Particle p2) {
    if(invertForces) {
      return 1*distProportion(p1, p2)*repulsions.get(p1.getType()).get(p2.getType());//The proportionality due to the distance times the value of the repulsive force
    }
    else {
      return -1*distProportion(p1, p2)*repulsions.get(p1.getType()).get(p2.getType());//The proportionality due to the distance times the value of the repulsive force
    }
    
  }
  
  public void updateCoords() {
    x += vx;
    y += vy;
    
    if(x+getSize()/2.0>WIDTH) {
      x -= (x+getSize()/2.0-WIDTH);//difference between current rightmost position and the width
      vx *= -LOSS_FACTOR;
    }
    if(x-getSize()/2.0<0){
      x = getSize()/2.0;
      vx *= -LOSS_FACTOR;
    }
    if(y+getSize()/2.0>HEIGHT) {
      y = HEIGHT-1-getSize()/2.0;
      vy *= -LOSS_FACTOR;
    }
    if(y-getSize()/2.0<0){
      y = getSize()/2.0;
      vy *= -LOSS_FACTOR;
    }
    
    ////Keep corner huggers out
    //if(x<10&&y<10){
    //  allParticles.remove(this);//To keep particles from being in the upper left corner
    //}
    
    
    
  }
  
  public static void collide(){
    //Collide with all particles:
    for(int i = 0; i < allParticles.size(); i++){
      Particle p = allParticles.get(i);
      for(int j = 0; j < allParticles.size(); j++){
        if(i==j){continue;}
        
        Particle p2 = allParticles.get(j);
        if(dist(p2, p)<p2.getSize()/2.0+p.getSize()/2.0){
        p2.setVX(p2.getVX()*-LOSS_FACTOR);
        p2.setVY(p2.getVY()*-LOSS_FACTOR);
        double overlap = -1*(dist(p2, p)-p2.getSize()/2.0-p.getSize()/2.0);
        
        //Opposite of x component of overlap
        p2.setX(p2.getX()+-1*overlap*Math.cos(Particle.getAngle(p2, p)));
        p2.setY(p2.getY()+-1*overlap*Math.sin(Particle.getAngle(p2, p)));
        
        p.setVX(p.getVX()+2*p2.getVX()*-LOSS_FACTOR);//In order for momentum to be conserved, the net momentum musn't change in a collision. Since momentum is a vector, reversing it on one end means that it must have been hit with twice that momentum on the other end in the opposite direction
        p.setVY(p.getVY()+2*p2.getVY()*-LOSS_FACTOR);//Should it be negative? ADDENDUM: YES IT SHOULD
        p.setX(p.getX()+-1*overlap*Math.cos(Particle.getAngle(p, p2)));
        p.setY(p.getY()+-1*overlap*Math.sin(Particle.getAngle(p, p2)));
      }
      }
        
    }
  }
  
  public double getX() {
    return x;
  }
  public double getY() {
    return y;
  }
  public double getXComponent(double force, double theta) {
    return Math.cos(theta)*force;
  }
  public double getYComponent(double force, double theta) {
    return Math.sin(theta)*force;
  }
  
  public static double getAngle(Particle p1, Particle p2) {
    double deltaX = p2.getX()-p1.getX();
    double deltaY = p2.getY()-p1.getY();
    return Math.atan2(deltaY, deltaX);
  }
  
  public int getType() {
    return type;
  }
  
  public int getSize(){
    return size;
  }
  
  public static void specifyTypeRepulsions(double[][] repulsionValues) {//make the double layered arraylist from a 2d array, which is easier to write beforehand
    numTypes = repulsionValues.length;
    types = new ArrayList<Integer>();
    for(int i = 0; i < repulsionValues.length; i++) {//adding all types to the types list
      types.add(i);
    }
    repulsions = new ArrayList<ArrayList<Double>>();
    for(int i = 0; i < repulsionValues.length; i++) {
      repulsions.add(new ArrayList<Double>());
      for(int j = 0; j < repulsionValues[i].length; j++) {
        repulsions.get(i).add(repulsionValues[i][j]);
      }
    }
  }
  
  /**
   * 
   * @param s A string wherein the first line specifies the number of particle types, and each subsequent line is a particle of type "line number minus one" and a series of space-separated doubles specifying how the particles should repel each other. Since I've used the word "repel" everywhere, a negative value will indicate a pull instead of a push. This will only make sense if the input is square, since every particle type should relate to every other particle type in some way. The index in terms of how many doubles to the right of the newline for each double in each line indicates the particle type that it relates to.
   * @return A 2D array representing the relationships between each particle and all other particles
   */
  public static double[][] stringToRepulsions(String s){
    Scanner sc = new Scanner(s);
    
    System.out.println(s);//Checking the input for reference
    
    int numTypesSpecified = sc.nextInt();
    sc.nextLine();
    
    double[][] repulsionOutput = new double[numTypesSpecified][numTypesSpecified];
        
    for(int i = 0; i < numTypesSpecified; i++) {
      for(int j = 0; j < numTypesSpecified; j++) {
        repulsionOutput[i][j] = sc.nextDouble();
      }
      sc.nextLine();
    }
    
    sc.close();
    
    return repulsionOutput;
  }
  
  public static double[][] formattedStringToRepulsions(String s){
    s = s.substring(1,s.length()-1);
    String[] input = s.split("]");
    input[0] = input[0].substring(1, input[0].length());//First one has no space before it
    for(int i = 1; i < input.length; i++){
      input[i] = input[i].substring(3, input[i].length());
    }
    //System.out.println(Arrays.toString(input));//Checking the input for reference
    
    double[][] repulsionOutput = new double[input.length][];
    for(int i = 0; i < input.length; i++){
      String[] nums = input[i].split(", ");
      repulsionOutput[i] = new double[nums.length];
      for(int j = 0; j < nums.length; j++){
        repulsionOutput[i][j] = Double.parseDouble(nums[j]);
      }
    }
        
    return repulsionOutput;
  }

  
  public static void setColor(int type, Color c) {
    allColors.put(type, c);
  }
  
  public static void updateAll() {
    for(Particle p: allParticles) {
      p.updateVelocity();
    }
    for(int i = 0; i < allParticles.size(); i++) {
      Particle p = allParticles.get(i);
      p.updateCoords();
      
      if(printOnIteration) {
        System.out.println(p.toString());
      }
    }
    Particle.collide();
  }
  public static void drawAll() {
    for(Particle p: allParticles) {
      p.drawOne();
    }
  }
  
  public static void updateAndDraw() {
    updateAll();
    drawAll();
  }
  
  public static String fileToString(String fileName) {
    String output = "";
    try {      
      Scanner sc = new Scanner(new File(fileName));
      StringBuilder s = new StringBuilder();
      while(sc.hasNextLine()) {
        s.append(sc.nextLine() + "\n");
        sc.close();
      }
      output = s.toString();
      
    } catch (FileNotFoundException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }
    
    return output;
  }
  
  public double getVX(){
    return vx;
  }
  public void setVX(double vx){
    this.vx = vx;
  }
  public double getVY(){
    return vy;
  }
  public void setVY(double vy){
    this.vy = vy;
  }
  public void setX(double x){
    this.x = x;
  }
  public void setY(double y){
    this.y = y;
  }
  
  public static void randomizeColors(int numTypes){
    for(int i = 0; i < numTypes; i++){
      Particle.setColor(i, new Color((int)(Math.random()*255),(int)(Math.random()*255),(int)(Math.random()*255)));
    }
  }
  
  @Override
  public String toString() {
    return "PARTICLE\nType: " + type + "\nSize: " + size +  "\nColor: " + allColors.get(this.type) + "\n(X,Y): (" + x + "," + y + ")\n(VX,VY): (" + vx + "," + vy + ")\nRepulsions: " + repulsions.get(this.type).toString() + "\n\n";
  }
  
  public static void randomizeTypeRepulsions(int numTypes, double factor){
    double[][] output = new double[numTypes][numTypes];
    for(int i = 0; i < output.length; i++){
      for(int j = 0; j < output[i].length; j++){
        output[i][j] = Math.random()*factor-(Math.random()*factor/2.0);
      }
    }
    specifyTypeRepulsions(output);
  }
