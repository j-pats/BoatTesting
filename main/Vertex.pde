class Vertex {
  // attributes
  float x, y, z;
  
  public Vertex(float xn, float yn, float zn) {
    this.x = xn;
    this.y = yn;
    this.z = zn;
  }
  
  void drawVertex(){
    point(this.x, this.y, this.z);
  }
  
  void setY(float ny) {
    this.y = ny;
  }
  
  float getX() {
    return this.x;
  }

  float getY() {
    return this.y;
  }

  float getZ() {
    return this.z;
  }

}
