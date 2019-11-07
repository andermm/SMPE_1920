library("tidyverse")
df <- read.csv("/home/anderson/Desktop/GIT/SMPE_1920/LOGS/npb.02-11-2019.21h37m51s.csv")

df$kernel=toupper(df$kernel) 

df %>%
  group_by(kernel,interface) %>%
  summarise(
    mean=mean(time),
    sd=sd(time),
    se=sd/sqrt(n()),
    N=n()) %>%
  arrange(kernel,interface) -> newdf
newdf

dfplot<- ggplot(newdf[newdf$kernel %in% c("BT", "SP"), ] , aes(x=kernel, y=mean, fill=interface)) +
geom_bar(stat="identity", position = "dodge", width = 0.3) +
geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd), width=.2, position = position_dodge(.3)) +
theme_minimal() +
  
scale_fill_manual(values=c("#006dff", "#5ca3ff", "#b2d3ff"), name="Network\nInterface",
breaks=c("ETH", "IB", "IPoIB"), labels=c("Ethernet", "InfiniBand", "IP-over-IB")) +
  
theme(legend.position = c(0.15, 0.85), legend.background = element_rect(color = "black",
size = 0.3, linetype = "solid"), axis.text=element_text(size=12), 
axis.title=element_text(size=12), legend.title = element_text(color = "black", size = 14),
legend.text = element_text(color = "black", size = 12)) +
labs(x="Application", y="Execution Time [s]")
print(dfplot)
ggsave(dfplot, file="/home/anderson/Desktop/GIT/SMPE_1920/PLOTS/teste.png")
