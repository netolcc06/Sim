#include <GL/glut.h>
#include <iostream>
#include <time.h>
#include <vector>

#include <fstream>
#include <sstream>	

#include "Polygon.hpp"
#include "Line.hpp"
#include "glm/glm/vec2.hpp"

/**
 * This code reads a polygon with n vertices (vx, vy) | (-1 <= vx <= 1) and (-1 <= vy <= 1)
 * and generates 64 lines that may or not cross the polygon. The parts of the lines inside the polygon
 * are colored green and the outside parts are colored gray.
 * To compile this code: g++ main.cpp -o <name of the object> -lGL -lglut -Wall
 */


using namespace std;

// This is the polygon we are going to read from the input file
Polygon polygon; 

// These are the lines.
vector<Line<double> > lines;

/**
 * The lines are described by three parameters according to 
 * the equation ay + bx + c = 0. createLines randomly chooses
 * a, b, c in a [-99, 99] range. Since a line is function, a = 0 
 * is not allowed.
 */
void createLines(){

	srand(time(NULL));
	// nega, negb, negc are created aiming to provide negative values for a, b and c
	int a, b, c, nega, negb, negc;
	
	// Two possibilities: rand()%2==0 => negative number; rand()%2==1 => positive number;
	nega = rand()%2; negb = rand()%2; negc = rand()%2;
	if(nega==0) nega=-1; if(negb==0) negb=-1; if(negc==0) negc=-1;
	
	// The 64 lines are generated
	for(unsigned int i=0; i<64; i++){
		// a cannot be equal to 0
		a = rand()%100+1;
		b = rand()%100;
		c = rand()%100;
		lines.push_back(Line<double>(nega*a, negb*b, negc*c));
	}

}


/**
 * The function initializes the global variables of the program.
 * Here we read the vertices positions from an input file and add them
 * to our polygon.
 * After that we create the lines and their intersections with the polygon.
 */
 
void Init(int * argc, char * argv[])
{

	std::ifstream in_file;
	const char* filename= argv[1];
	in_file.open(filename);

	// Reading the file with the vertices positions
	if(!in_file.is_open()){
		cout << "Come back later with an input file, my friend" << endl;
		exit(0);
	}

	std::string line, op;
	std::stringstream linestream;
	float in_x, in_y;

	while (std::getline(in_file, line))
	{
		linestream << line;
		// First number in the line
		linestream >> in_x ;
		// The comma separating the two numbers
		linestream >> op;
		// Second number in the line
		linestream >> in_y;			

		// The polygon is filled with the vertices coordinates obtained from the file
		polygon.addVertex(glm::vec2(in_x, in_y));

		linestream.clear();
	}


	/**
	 * The window space where the polygon lies in has width and height equal to 2.
	 * The inferior left point has coordinates (-1.0, -1.0).
	 * The superior right point has coordinates (1.0, 1.0).
	 * Given that, the x's and y's vertices coordinates of the polygon need to lie into the [-1, 1] interval.
	 * The coordinates below specifie the four corners of the window.
	 * EVERY line needs to be tested against the 4 edges of the window because we need the first and
	 * last intersection points in the screen space.
	 */
	glm::vec2 upleft(-1.0,1.0), upright(1.0,1.0), downleft(-1.0,-1.0), downright(1.0,-1.0);

	createLines();
	
	// Calculate the points where the lines intersect the polygon and the screen
	for(unsigned int z=0; z<64; z++){

		// Firstly, calculates the intersections with the screen
		lines[z].intersect(upleft, upright); lines[z].intersect(downleft, downright);
		lines[z].intersect(upleft, downleft); lines[z].intersect(upright, downright);
	
		// Finally, the intersections with the polygons
		for(unsigned int it=0; it< polygon.vertices.size(); it++)
			lines[z].intersect(polygon.vertices[it], polygon.vertices[(it+1)%polygon.vertices.size()]);

	}
}

/**
 * Used to draw the elements on the screen.
 */
void Desenha()
{
	// Clear the screen with the white color
    glClearColor(1.0f, 1.0f, 1.0f, 0);
    glClear(GL_COLOR_BUFFER_BIT);

	// Draw the lines
	for(unsigned int z=0; z<64; z++)
		lines[z].draw();

	// Draw the polygons
	polygon.draw();

    glutSwapBuffers();

}  

/**
 * Callback function for drawing.
 */
void dpdraw1()
{
     Desenha();
}

/**
 * Keyboard callback function. Just exit the program when you press ESC.
 */
void Teclado(unsigned char tecla, int x, int y)
{
	// key 27 == ESC
    if(tecla==27)
	{
		// Ends the program
        exit(0);  
    }
}

/**
 * Main function. Basically it creates the main window and registers the glut callback functions.
 */
int main(int argc, char* argv[])
{
	
    Init(&argc,argv);
 
    glutInit(&argc,argv);

    glutInitWindowSize(600,600);

    glutCreateWindow("\t \t \t \t \t \t.:: LINES::.");
    
    glutSetCursor(GLUT_CURSOR_NONE);
    
	glutKeyboardFunc(Teclado);// Keyboard callback function.

    glutDisplayFunc(dpdraw1);// Draw callback function.

    glutMainLoop();

}
