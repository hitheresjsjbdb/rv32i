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

#include <isa.h>

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>
#include <string.h>
#include <common.h>
#include <memory/paddr.h>

enum {
  TK_NOTYPE = 256, TK_EQ,

  /* TODO: Add more token types */
  TK_HEX, TK_DEC, TK_MINUS, TK_AND, TK_REG, TK_NEQ, TK_DEREF

};

static struct rule {
  const char *regex;
  int token_type;
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */

  {" +", TK_NOTYPE},    // spaces
  {"\\+", '+'},         // plus
  {"-", '-'},           // minus
  {"\\*", '*'},         // times
  {"/", '/'},           // divide
  {"\\(", '('},         // left bracket
  {"\\)", ')'},         // right bracket
  {"==", TK_EQ},        // equal
  {"!=", TK_NEQ},       // not equal
  {"&&", TK_AND},       // and
  {"\\$[a-zA-Z0-9]+", TK_REG},    // reg name
  {"0[xX][0-9a-fA-F]+", TK_HEX},  // hex numbers
  {"[0-9]+", TK_DEC}    // dec numbers
};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token {
  int type;
  char str[32];
} Token;

static Token tokens[32] __attribute__((used)) = {};
static int nr_token __attribute__((used))  = 0;
int length_token = 0;

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;
  length_token = 0;

  while (e[position] != '\0') {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
        // char *substr_start  = e + position;
        int substr_len = pmatch.rm_eo;

        // Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
        //     i, rules[i].regex, position, substr_len, substr_len, substr_start);

        // position += substr_len;

        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */

        switch (rules[i].token_type) {
          case TK_NOTYPE: break;
          default:
            tokens[nr_token].type = rules[i].token_type;
            strncpy(tokens[nr_token].str, e + position, substr_len);
            tokens[nr_token].str[substr_len] = '\0';
            nr_token++;
            length_token++;
            break;
        }

        position += substr_len;

        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }
  return true;
}

static bool is_bad_expression;
static bool check_parentheses(int p, int q) {
  if (p > q) return false;
  is_bad_expression = false;
  int stack = 0;
  bool is_full_parenthesed = true;
  for (int i = p; i <= q; i++) {
    if (tokens[i].type == '(') stack++;
    else if (tokens[i].type == ')') {
      if (stack == 0) {
        is_bad_expression = true;
        return false;
      }
      else stack--;
    }
    if (stack == 0 && i != q) {
      is_full_parenthesed = false;
    }
  }
  if (stack != 0) {
    is_bad_expression = true;
    return false;
  }
  
  return is_full_parenthesed;
}

static int get_op_precedence(int op_type) {
  switch (op_type) {
    case '(': case ')':
    return 0;
    case TK_MINUS: case TK_DEREF:
    return 1;
    case '*': case '/':
    return 2;
    case '+': case '-':
    return 3;
    case TK_EQ: case TK_NEQ:
    return 4;
    case TK_AND:
    return 5;
    default: return -1;
  }
}

static int get_main_op(int p, int q) {
  int stack[32] = {};
  int stack_top = 0;
  for (int i = p; i <= q; i++) {
    int op_type = tokens[i].type;
    int precedence = get_op_precedence(op_type);

    if (precedence == -1) continue;
    else if (precedence != 0) {
      if (stack_top == 0) {
        stack[stack_top] = i;
        stack_top++;
      }
      else {
        if (precedence >= get_op_precedence(tokens[stack[stack_top-1]].type)) {
          stack[stack_top] = i;
          stack_top++;
        }
      }
    }
    else if (precedence == 0) {
      int j = i + 1;
      while (check_parentheses(i, j) == false) {
        j++;
      }
      i = j;
      assert(i <= q);
    }
  }
  return stack_top == 0 ? 0 : stack[stack_top-1];
}

static void tokenise() {
  if (tokens[0].type == '-') tokens[0].type = TK_MINUS;
  else if (tokens[0].type == '*') tokens[0].type = TK_DEREF;
  for (int i = 1; i < length_token; i++) {
    if (tokens[i].type == '-' || tokens[i].type == '*') {
      int op_type = tokens[i-1].type;
      if (op_type == '+' || op_type == '-' || op_type == '*' || op_type == '/' || op_type == '(') {
        tokens[i].type = tokens[i].type == '-' ? TK_MINUS : TK_DEREF;
      }
    }
  }
}

__attribute__((used)) static uint32_t eval (int p, int q) {
  if (check_parentheses(p, q) == false && is_bad_expression == true) {
    printf("It's a bad expression\n");
    return 0;
  }
  if (p > q) {
    return 0;
  }
  else if (p == q) {
    uint32_t val = 0;
    bool success;
    switch (tokens[p].type) {
      case TK_DEC: return atoi(tokens[p].str);
      case TK_HEX:
        sscanf(tokens[p].str, "%x", &val);
        return val;
      case TK_REG:
        val = isa_reg_str2val(tokens[p].str, &success);
        if (success) return val;
        else {
          printf("Failed to get the value of %s\n", tokens[p].str);
          return 0;
        }
      default: assert(0);
    }
  }
  else if (check_parentheses(p, q) == true) {
    /* The expression is surrounded by a matched pair of parentheses.
     * If that is the case, just throw away the parentheses.
     */
    return eval(p + 1, q - 1);
  }
  else {
    int op = get_main_op(p, q);
    int op_type = tokens[op].type;
    uint32_t val1 = eval(p, op - 1);
    uint32_t val2 = eval(op + 1, q);

    switch (op_type) {
      case '+': return val1 + val2;
      case '-': return val1 - val2;
      case '*': return val1 * val2;
      case '/':
        if (val2 != 0) return val1 / val2;
        else return 0;
      case TK_EQ:    return val1 == val2;
      case TK_NEQ:   return val1 != val2;
      case TK_AND:   return val1 && val2;
      case TK_MINUS: return -val2;
      case TK_DEREF:
        if (!in_pmem(val2)) {
          printf("address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD "\n",
            val2, PMEM_LEFT, PMEM_RIGHT, cpu.pc);
        }
        else        return paddr_read(val2, 4);
      default:      return 0;
    }
    return 0;
  }
  return 0;
}

word_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }

  /* TODO: Insert codes to evaluate the expression. */
  //TODO();

  tokenise();   // differentiate '-' and MINUS, '*' and DEREF

  *success = true;
  return eval(0, length_token - 1);

}

