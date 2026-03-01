#include "unity.h"

/* additional tests; runner handles setup/main */

void test_fail(void) {
    /* this assertion will fail */
    TEST_ASSERT_EQUAL_INT(3, 1 + 1);
}

void test_ignore(void) {
    TEST_IGNORE_MESSAGE("demonstration of ignore");
}
