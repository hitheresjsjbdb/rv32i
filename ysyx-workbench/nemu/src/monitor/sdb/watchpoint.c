/***************************************************************************************
* Copyright (c) 2014-2024 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include "sdb.h"

#define NR_WP 32

enum { REG, MEM };

static WP wp_pool[NR_WP] = {};
static WP *head = NULL, *free_ = NULL;

void init_wp_pool() {
  int i;
  for (i = 0; i < NR_WP; i ++) {
    wp_pool[i].NO = i;
    wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
  }

  head = NULL;
  free_ = wp_pool;
}

/* TODO: Implement the functionality of watchpoint */

void wp_display() {
  WP *wp = head;
  if (wp == NULL) {
    printf("No watchpoint\n");
    return;
  }

  printf("No. | content\n");
  while (wp != NULL) {
    printf("%3d | %s\n", wp->NO, wp->str);
    wp = wp->next;
  }

}

WP* new_wp() {
  if (free_ == NULL) {
    printf("There is no free watchpoint\n");
    return NULL;
  }

  WP *temp = head;
  head = free_;
  free_ = free_->next;
  head->next = temp;

  return head;
}

void free_wp(int n) {
  
  if (head == NULL) {
    printf("There is no activated watchpoint\n");
    return;
  }

  WP *wp_pre = head;
  WP *wp = wp_pre->next;

  if (n == head->NO) {
    wp = head;
    head = wp->next;
    wp->next = free_;
    free_ = wp;
    return;
  }

  while (wp_pre->next != NULL && wp_pre->next->NO != n) {
    wp_pre = wp_pre->next;
  }
  wp = wp_pre->next;
  if (wp == NULL) {
    printf("No.%d watchpoint is not activated\n", n);
    return;
  }
  wp_pre->next = wp->next;
  wp->next = free_;
  free_ = wp;

}

void check_wp(bool *triggered) {
  WP *wp = head;
  *triggered = false;
  if (wp == NULL) return;
  bool success;
  while (wp != NULL) {
    bool title = true;
    int val = expr(wp->str, &success);
    assert(success == true);
    if (val != wp->last_value) {
      *triggered |= 1;
      if (title) printf("No. | content %*.s | previous value | current value \n", 20, "");
      title = false;
      printf(" %2d | %28s |     0x%08x |    0x%08x \n", wp->NO, wp->str, wp->last_value, val);
      wp->last_value = val;
      wp = wp->next;
    }
    else {
      *triggered |= 0;
      wp = wp->next;
    }
  }
}