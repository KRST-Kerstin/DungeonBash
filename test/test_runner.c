#include "unity.h"

/* prototypes for tests defined elsewhere */
void test_addition(void);
void test_fail(void);
void test_ignore(void);

void setUp(void) {}
void tearDown(void) {}

int main(void) {
    UNITY_BEGIN();
    RUN_TEST(test_addition);
    RUN_TEST(test_fail);
    RUN_TEST(test_ignore);
    return UNITY_END();
}
