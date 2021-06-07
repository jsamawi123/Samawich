//BY JAMES H SAMAWI 

#pragma once	//in order to run main by itself
#include <iostream>
#include <string>

//using namespace std; Not industry standard

class GroceryItem {

public:

	//Default Constructor:
	GroceryItem() : GroceryItem(" ", 0, 0.0, false) { //Default values
													  //cout << "GroceryItem Default Constructor called..." << endl; //Test
	}

	//Copy Constructor:
	GroceryItem(const std::string& name, const int& quantity, const float& unitPrice, const bool& taxable)
		: name_(name), quantity_(quantity), unitPrice_(unitPrice), taxable_(taxable) {} //Deep copy all these constant values

																						//Destructor:
	~GroceryItem() {}


	//----------get/setName()--------------//
	std::string getName() const {

		return name_; //string 
	}
	void setName(const std::string& n) {
		name_ = n;
	}
	//----------get/setQuantity()-----------//
	int getQuantity() const {

		return quantity_; //int 
	}
	void setQuantity(const int& q) {
		quantity_ = q;
	}
	//----------get/setUnitPrice()----------//
	float getUnitPrice() const {

		return unitPrice_; //float
	}

	void setUnitPrice(const float& u) {
		unitPrice_ = u;
	}
	//----------is/setTaxable()----------//
	bool isTaxable() const {

		return taxable_; //boolean
	}
	void setTaxable(const bool& t) {
		taxable_ = t;
	}

	//Friend function:
	friend std::ostream &operator << (std::ostream &os, GroceryItem& item) {
		return os;
	}


private: //Class private member variables here:

	std::string name_;
	int quantity_;
	float unitPrice_;
	bool taxable_;

};
