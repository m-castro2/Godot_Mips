#include "stage.h"
#include <string>
#include <iostream>

using namespace std;

class MEM: public Stage {
public:
    string runStage() override {
        return ("Running stage " + stageName + "\n");
    }

    string run() {
            return "IF";
    }

    MEM() {
        stageName = "MEM";
    }

    ~MEM() override = default;
};
