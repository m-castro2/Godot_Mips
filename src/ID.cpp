#include "stage.h"
#include <string>
#include <iostream>

using namespace std;

class ID: public Stage {
public:
    string runStage() override {
        return ("Running stage " + stageName + "\n");
    }

    string run() {
            return "IF";
    }

    ID() {
        stageName = "ID";
    }

    ~ID() override = default;
};
//
