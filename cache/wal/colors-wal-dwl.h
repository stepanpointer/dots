/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }

static const float rootcolor[]             = COLOR(0x0e1521ff);
static uint32_t colors[][3]                = {
	/*               fg          bg          border    */
	[SchemeNorm] = { 0xc2c4c7ff, 0x0e1521ff, 0x5d6472ff },
	[SchemeSel]  = { 0xc2c4c7ff, 0x675549ff, 0x433C42ff },
	[SchemeUrg]  = { 0xc2c4c7ff, 0x433C42ff, 0x675549ff },
};
