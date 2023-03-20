#include "stage.h"
#include <string>
#include <iostream>

using namespace std;

class IF: public Stage {
    public:
        string runStage() override {
            return ("Running stage " + stageName + "\n");
        
        }
        string run() {
            return "IF";
        }

        IF() {
            stageName = "IF";
        }

        ~IF() override = default;
};