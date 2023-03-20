#include "stage.h"
#include <string>
#include <iostream>

using namespace std;

class EX: public Stage {
public:
    string runStage() override {
        return ("Running stage " + stageName + "\n");
    }

    string run() {
            return "IF";
    }

    EX() {
        stageName = "EX";
    }

    ~EX() override = default;
};