//BY JAMES H SAMAWI 

#pragma once		 //in order to run main by itself
#include <vector>
#include <iostream>
#include <fstream>	 //for files 
#include <stdexcept> //reporting errors
#include "GroceryItem.h"


//using namespace std; Not industry standard

class GroceryInventory {

private: //Class private member variables here:

	std::vector<GroceryItem> inventory_;
	float taxRate_;

public: //Class "prototypes" here:

	GroceryInventory();
	GroceryItem& getEntry(const std::string&);
	void addEntry(const std::string&, const int&, const float&, const bool&);
	float getTaxRate() const;
	void setTaxRate(const float&);
	void createListFromFile(const std::string&);
	float calculateUnitRevenue() const;
	GroceryInventory& operator[] (const GroceryInventory&);
	GroceryInventory(const GroceryInventory&);
	~GroceryInventory();

};


void GroceryInventory::createListFromFile(const std::string& filename) {

	std::ifstream input_file(filename);

	//Opens "shipment.txt" in main test code

	if (input_file.is_open()) { //IF the file OPENS...

		std::cout << "Successfully opened file " << filename << std::endl; //Test

																		   //variables only accessible in if statement:
		std::string name;
		int quantity;
		float price;
		bool taxable;

		while (input_file >> name >> quantity >> price >> taxable) { //loop while file is accessing vars

			addEntry(name, quantity, price, taxable);
		}

		input_file.close(); //Closes file!

	}
	else { //IF the file DOESN'T open...

		throw std::invalid_argument("Could not open file " + filename);

	}// end of if-else statement

}// end of createListFromFile()


GroceryInventory::GroceryInventory() { //Default Constructor:

	std::cout << "GroceryInventory Default Constructor called..." << std::endl; //Test

}


GroceryItem& GroceryInventory::getEntry(const std::string& findname) {

	//Task: To find the entry name when asked. A solution is to make a simple search algorithm 
	//that goes line by line trying to find the name then returns the LOCATION. Of course, if it 
	//can't find the name it throws back an error.

	std::cout << "getEntry called..." << std::endl; //Test

	for (size_t i = 0; i < inventory_.size(); ++i) { //searches inventory line by line. Big O notation: O(n).

		if (inventory_[i].getName() == findname) //IF the value of the ith location is equivalent to the search value...
		{
			return inventory_[i]; //Return location of name.

		}
		else { //IF it CAN'T find it..

			throw std::invalid_argument("Name not found"); //#include <stdexcept>
														   //break;
		}

	} //END of loop


}//END of getEntry //Error, reached end of non-void function


void GroceryInventory::addEntry(const std::string& name, const int& quantity, const float& price, const bool& taxable) {

	//Task: Find a way to add an entry's name, quantity, price, and whether it is taxable into "inventory_" vector.
	//For this, we will utilize the .resize() vector opperation that pushes back data in the inventory while at the same time
	//expands the size of the vector. Refer to www.cplusplus.com/reference/vector/vector/resize for more information. 

	//cout << "addEntry called..." << endl; //Test

	inventory_.resize(inventory_.size() + 1); //Expand size by 1

	inventory_[inventory_.size() - 1].setName(name);			//Subtract 1 from size to make space for name.
	inventory_[inventory_.size() - 1].setQuantity(quantity);	//for quantity.
	inventory_[inventory_.size() - 1].setUnitPrice(price);		//for price.
	inventory_[inventory_.size() - 1].setTaxable(taxable);		//for taxable.

}


//---------------------------------------------------//

float GroceryInventory::getTaxRate() const {

	return taxRate_; //Return member variable taxRate_ through the getter.
}

void GroceryInventory::setTaxRate(const float& tr) {

	taxRate_ = tr; //Setter temporarily sets tr equal to taxRate_.
}

//---------------------------------------------------//


float GroceryInventory::calculateUnitRevenue() const {

	//Task: Calculate the total shipment revenue. We should take into account the price and quantity of each 
	//item in the list. Find a way to access all parts of the inventory, and by doing so, calculate the summation of 
	//the product of price and quantity. Store this newfound value, add it to the total price revenue, and return it.

	//variable declarations:
	float pq = 0.0000;			//Let pq = price times quantity
	float revenue = 0.0000;		//what we will return, the revenue

								//Utitlize a size for-loop...
	for (size_t k = 0; k < inventory_.size(); ++k) {

		pq = inventory_[k].getUnitPrice() * inventory_[k].getQuantity(); // pq = Price * Quantity (call the getters)
		revenue = revenue + pq; //keep incrementing revenue as the loop goes.

	}

	return revenue; //Returns Shipment Total.

}

GroceryInventory::GroceryInventory(const GroceryInventory& e)  //Copy Constructor
{
	inventory_ = e.inventory_; //A test for copying inventories
}

GroceryInventory& GroceryInventory::operator[](const GroceryInventory& other) { //Assignment operator

	return *this; //Returns pointer

}

GroceryInventory::~GroceryInventory() {} //Destructor
