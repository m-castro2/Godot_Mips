#include "stage.h"
#include <string>
#include <iostream>

using namespace std;

class WB: public Stage {
public:
    string runStage() override {
        return ("Running stage " + stageName + "\n");
    }

    string run() {
            return "IF";
    }

    WB() {
        stageName = "WB";
    }

    ~WB() override = default;
};
