#include "unity.h"

/* simple unit test; runner provides setUp/tearDown and main */

void test_addition(void) {
    TEST_ASSERT_EQUAL_INT(2, 1 + 1);
}
