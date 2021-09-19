library(hexSticker)
library(showtext)
## Loading Google fonts (http://www.google.com/fonts)
font_add_google("Arvo", "arvo")
## Automatically use showtext to render text for future devices
showtext_auto()

plot(sticker("/twitmo_hex.png", package="Twitmo",
        p_size=8, p_y = 1.48 , s_x=1, s_y=0.7, s_width=1.3, s_height = 1.3, dpi = 600,
        filename="man/figures/hexSticker.png", p_family = "arvo", h_fill="#1D9BF0", h_color = "#1D9BF0",
        spotlight = T))
