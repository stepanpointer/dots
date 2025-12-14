const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#0e1521", /* black   */
  [1] = "#433C42", /* red     */
  [2] = "#675549", /* green   */
  [3] = "#88613C", /* yellow  */
  [4] = "#8D7257", /* blue    */
  [5] = "#A48C6D", /* magenta */
  [6] = "#C8A171", /* cyan    */
  [7] = "#c2c4c7", /* white   */

  /* 8 bright colors */
  [8]  = "#5d6472",  /* black   */
  [9]  = "#433C42",  /* red     */
  [10] = "#675549", /* green   */
  [11] = "#88613C", /* yellow  */
  [12] = "#8D7257", /* blue    */
  [13] = "#A48C6D", /* magenta */
  [14] = "#C8A171", /* cyan    */
  [15] = "#c2c4c7", /* white   */

  /* special colors */
  [256] = "#0e1521", /* background */
  [257] = "#c2c4c7", /* foreground */
  [258] = "#c2c4c7",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
