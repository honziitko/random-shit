#include <stdio.h>

typedef float (*UnaryFloatFunc)(float);
UnaryFloatFunc derive(UnaryFloatFunc f, float dx);

float squaref(float x) {
    return x*x;
}

float f(float x) { return x*x*x + 2*x*x; }

#define EPS 0.0001f
int main() {
    UnaryFloatFunc timesTwo = derive(squaref, EPS);
    UnaryFloatFunc df = derive(f, EPS);
    printf("f(x) = x^2\n");
    for (int i = -5; i <= 5; i++) {
        printf("f'(%d) = %f\n", i, timesTwo(i));
    }
    printf("f(x) = x^3 + 2x^2\n");
    for (int i = -5; i <= 5; i++) {
        printf("f'(%d) = %f\n", i, df(i));
    }
}
