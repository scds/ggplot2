
# Data visualization with ggplot2
# Isaac Kinley
# April 19, 2022

# Introduction ########################

# Load/install ggplot2
if (!require(ggplot2)) {
  install.packages('ggplot2')
  library(ggplot2) # Usually your code would contain only this line
}

# View the data we'll be working with
print(mpg)
# Note the "tidy" format: one observation per row, one variable per column.

# We can do a "quick plot" to achieve a similar functionality to base R's plot()
# function
plot(mpg$cty, mpg$hwy)
qplot(cty, hwy, data = mpg)

# Basic syntax of creating a plot:
plot.base <- ggplot(
  data = mpg, # Specify the data
  mapping = aes( # Specify the aesthetic mapping
    x = cty,
    y = hwy
  )
) # Note that this doesn't plot anything---it just creates a base to build on

# We can then add layers using the + operator

plot.base + geom_point() # Reproduces qplot

plot.base + geom_point() + geom_smooth() # Adds a local regression line

# Note that variable assignment don't cause anything to print, so a ggplot
# doesn't show up on the plots panel when it's assigned to a variable

# I.e.:

1 + 1 # Causes "2" to appear in the console
plot.base + geom_point(color = 'orange') # Causes a plot to appear in the plots panel

x <- 1 + 1 # Nothing prints
img <- plot.base + geom_point(color = 'blue') # Nothing displays

# But we can make them display:
print(x)
print(img)
plot(img) # Works the same way

# The values you can specify in the aesthetic mapping include (but are not
# limited to!) the following:

# x
# y
# colour
# fill
# linetype
# shape
# size
# alpha

# We'll see these in action shortly

dev.off() # Deletes all plots from the plots panel

# Plots of categorical data ########################

# Bar plot
ggplot(
  data = mpg, 
  mapping = aes(y = drv)
) + geom_bar()

# Plot of contingency table
ggplot(
  data = mpg,
  mapping = aes(x = drv, y = fl)
) + geom_bin_2d()

# Stacked bar plot
ggplot(
  data = mpg,
  mapping = aes(x = drv, fill = fl)
) + geom_bar(position = 'stack', width = 0.5)

# Bar plots of sub-distributions
ggplot(
  data = mpg,
  mapping = aes(x = drv, fill = fl)
) + geom_bar(position = 'dodge')

# Ensure the widths of the individual bars are consistent
ggplot(
  data = mpg,
  mapping = aes(x = drv, fill = fl)
) + geom_bar(position = position_dodge2(preserve = 'total'))

dev.off()

# Plots of one-dimensional continuous data ########################

# Histogram:
ggplot(
  data = mpg,
  mapping = aes(x = hwy)
) + geom_histogram(binwidth = 1)

# Rug plot
fake.data <- data.frame(
  fake.obs = rnorm(100)
)
ggplot(
  data = fake.data,
  mapping = aes(x = fake.obs)
) + geom_rug()

# Kernel density estimate
ggplot(mpg, aes(x = hwy)) +
  geom_density()

dev.off()

# Plots of two-dimensional continuous data ########################

# Setting up base of plots (note the colour!)
plot.base <- ggplot(
  data = mpg,
  mapping = aes(x = cty, 
                y = hwy, 
                colour = drv)
)

# Scatterplot
plot.base + geom_point()
# Note the overlapping points
# We could add transparency:
plot.base + geom_point(alpha = 0.2)
# Or add jitter
set.seed(123)
plot.base + geom_point(position = 'jitter')
# Or change the point size based on how many are overlapping
plot.base + geom_count(alpha = 0.4) # With a little transparency as well...
plot.base + geom_count() # ...because there's no guarantee that smaller points
# won't be hidden by larger points

# 2-d kernel density plots
plot.base <- ggplot(
  data = mpg,
  mapping = aes(
    x = cty, 
    y = hwy
  )
)
plot.base + geom_density_2d()
plot.base + geom_density_2d_filled()

# Adding lines of best fit
plot.base + geom_point(position = 'jitter') +
  geom_smooth()
plot.base + geom_point(position = 'jitter') +
  geom_smooth(method = lm, formula = y ~ x)

# Suppose we want to plot a nonlinear trendline based on some model of the data.

# First, let's create some fake data
x <- seq(1, 20, length.out = 100)
y <- 3*sqrt(x) + rnorm(100)
df <- data.frame(
  x = x,
  y = y
)
# Next, let's create a model of our data
mod <- nls(
  formula = y ~ k*sqrt(x),
  data = df
)
# Next, let's get the predictions of the data
pred.data <- data.frame(
  x = seq(1, 20, length.out = 300)
)
pred.data$y <- predict(mod, pred.data)
# Next, let's overlay these predictions over the data. To do so, we can override
# the original data with the prediction data within the geom_line function
ggplot(
  data = df,
  mapping = aes(
    x = x,
    y = y
  )
) + 
  geom_point() +
  geom_line(data = pred.data)

dev.off()

# Correlation heatmap ########################

# Plot of correlation matrix
cor.mat <- cor(mpg[, c('displ', 'cty', 'hwy')])
print(cor.mat)
# Remove redundant entries
cor.mat[!upper.tri(cor.mat)] <- NA
diag(cor.mat) <- 1
print(cor.mat)
# Convert to a data frame
df <- as.data.frame(as.table(cor.mat), responseName = 'correl')
print(df)

ggplot(
  data = df,
  mapping = aes(
    x = Var1, 
    y = Var2, 
    fill = correl)) +
  geom_tile()

ggplot(df, aes(x = Var1, y = Var2, fill = correl)) +
  geom_tile() +
  geom_text( # Plus some text
    colour = 'white',
    aes(label = round(correl, 2))
  ) +
  scale_fill_continuous(na.value = NA) # Make the missing tiles transparent

dev.off()

# Mixed continuous and categorical variables ########################

plot.base <- ggplot(
  data = mpg,
  mapping = aes(
    x = factor(year),
    fill = factor(year),
    y = cty
  )
)

# Boxplot
plot.base + geom_boxplot()

# Violin plot
plot.base + geom_violin()

# Boxplot + violin (personal favourite)
plot.base + geom_violin(fill = 'white') + geom_boxplot(width = 0.25)

# Bar plot with error bars
plot.base +
  geom_bar(stat = 'summary', fun = mean, width = 0.5) +
  geom_errorbar(stat = 'summary', fun.data = mean_se, width = 0.2)

# Plots of paired data (e.g., multiple observations from the same individuals
# across time)
df <- data.frame(
  id = rep(1:50, each = 3),
  t = rep(1:3, times = 50),
  obs = rnorm(150, mean = rep(c(0, 1, 2), 50))
)
plot.base <- ggplot(
  data = df,
  mapping = aes(
    group = id,
    x = t,
    y = obs
  )
)
plot.base + geom_point() + geom_line()

# Add boxplots
plot.base + geom_point() + geom_line(alpha = 0.5) +
  geom_boxplot(
    width = 0.5,
    fill = NA,
    mapping = aes( # Note that we have to override the original aesthetic mapping
      group = t
    )
  )

dev.off()

# Different panel for each value of a categorical variable ########################

plot.base <- ggplot(
  data = mpg,
  mapping = aes(
    x = hwy,
    y = cty
  )
)

cty.hwy <- plot.base + geom_point()

cty.hwy + facet_wrap(vars(trans))

# Or we could show a table for the interaction between two categorical variables

cty.hwy + facet_grid(rows = vars(year), cols = vars(cyl))

# vars() here is a "quoting" function---it allows the input to refer to a column
# in our dataframe rather than be interpreted as a variable

dev.off()

# Customizing your plot's appearance ########################

# As mentioned earlier, you can map certain aspects of your plot's appearance to
# variables in the data. But you can also change those aspects of your plot's
# appearance in a way that ignores the data

plot.base <- ggplot(
  data = mpg,
  mapping = aes(
    x = hwy,
    y = cty,
    colour = fl
  )
)

plot.base + geom_point(
  shape = 21,
  colour = 'green',
  fill = 'lightblue',
  size = 3,
  alpha = 0.5,
  stroke = 0.5 # Line thickness
)
# These aesthetic attributes apply regardless of any aspect of the data. We can
# use it to overwrite an aesthetic mapping within a particular layer

scatterplot <- plot.base + geom_point()
print(scatterplot) # Without overriding, the colour is mapped to fuel class

# We an also transform the axes...
scatterplot + scale_y_log10()

# ...and customize the labels...
scatterplot + labs(
  title = 'Fuel efficiency',
  subtitle = 'City vs highway',
  x = 'Highway MPG',
  y = 'City MPG',
  colour = sprintf('Fuel\ntype')
)

# ...and customize the tick marks
scatterplot + scale_x_continuous(
  breaks = c(
    15, 
    25,
    35,
    45
  ),
  labels = c(
    'Fifteen',
    'Twenty five',
    'Thirty five',
    'Forty five'
  )
)

# You may want to customize the colour scale used

# If you're using a discrete colour scale, you can
# manually specify a list of colours to use
scatterplot <- plot.base + geom_point()
print(scatterplot)
scatterplot +
  scale_colour_manual(
    values = c(
      'c' = 'red',
      'd' = 'orange',
      'e' = 'green',
      'p' = 'blue',
      'r' = 'yellow'
    ),
    labels = c( # While you're at it, you can specify the labels
      'c' = sprintf('Compressed\nnatural\ngas'),
      'd' = 'Diesel',
      'e' = 'Ethanol',
      'p' = 'Premium',
      'r' = 'Regular'
    )
  )

# Or you can select from a pre-existing set of colour palettes
scatterplot + 
  scale_colour_brewer(palette = 'Set1')

# If you're using a continuous scale, you can customize the ends of the scale
ggplot(
  data = mpg,
  mapping = aes(
    x = hwy,
    y = cty,
    colour = displ
  )
) + 
  geom_point() +
  scale_colour_continuous(low = 'yellow', high = 'green')

# The theme() function is a very powerful tool for changing various aspects of
# your plot's appearance. The elements of the plot are arranged in a hierarchy,
# so that you can specify, e.g., the appearance of text in general and then
# overwrite this default for, e.g., the text of the axis tick labels
scatterplot +
  labs(
    title = 'Customized scatterplot',
    subtitle = 'using theme()'
  ) +
  theme(
    text = element_text(family = 'mono', colour = 'lightgoldenrod4'), # All text will be monospace and goldenrod colour by default
    title = element_text(face = 'bold'), # All titles will be bold
    legend.title = element_text(size = 15, hjust = 0.5),
    axis.title = element_text(face = 'bold.italic'), # both x and y
    legend.position = 'left',
    legend.key = element_blank(),
    axis.ticks = element_line(colour = NA),
    axis.text = element_text(colour = 'lightgoldenrod3', face = 'italic'),
    panel.grid = element_line(colour = 'lightgoldenrod1'),
    axis.line = element_line(colour = 'lightgoldenrod2'),
    panel.background = element_rect(fill = NA)
  )

# Various preset themes exist to change the overall appearance of the plot
scatterplot + theme_classic() # Personal favourite
scatterplot + theme_bw()

dev.off()

# What is the grammar? ########################

# The "GG" in ggplot stands for "grammar of graphics". It's a formal system for
# describing common types of visualizations, and it sees each layer as a
# combination of a statistical computation, a geometric object, a mapping to a
# coordinate system, etc., and these can all be mixed-and-matched to some
# extent. The advantage of this is that you can create a lot of different plot
# types from a few simple objects.

# E.g. ever notice how there's no geom_pie_chart()? It's because it's really
# just a horizontal stacked bar plot in polar coordinates.
(plot <- ggplot(mpg, aes(y = '', fill = class)) + geom_bar(position = 'stack'))
print(plot)
(plot <- plot + coord_polar())
print(plot)

# Because the geom_ functions compute some statistic on your data before
# displaying it, we can work with these computed statistics using after_stat()
ggplot(mpg, aes(x = hwy)) +
  geom_histogram()

ggplot(mpg, aes(x = hwy)) +
  geom_density()

ggplot(mpg, aes(x = hwy)) +
  geom_histogram() +
  geom_density()

ggplot(mpg, aes(x = hwy)) +
  geom_histogram(
    aes(
      y = after_stat(count/nrow(mpg))
    )
  ) +
  geom_density()

ggplot(mpg, aes(x = hwy)) +
  geom_histogram() +
  geom_density(
    aes(
      y = after_stat(density * nrow(mpg))
    )
  )

# Sometimes it makes sense to specify a layer in terms of the statistic to be
# computed rather than in terms of the geometric object to be drawn:
plot.base <- ggplot(mpg, aes(x = drv, y = hwy))
plot.base + stat_summary(fun = median, geom = 'bar')
plot.base + stat_summary(fun.data = mean_se, geom = 'pointrange')

# What's the difference between fun and fun.data here?

# fun returns a single number while fun.data returns a data frame with columns
# y, ymin, and ymax. We can see this when we use mean_se(), which is often used
# as the fun.data argument:

mean_se(rnorm(100))

# We can specify our own fun and fun.data:

plot.base + stat_summary(
  geom = 'point',
  fun = function(x) {return(30)}
)

plot.base + stat_summary(
  geom = 'pointrange',
  fun.data = function(d) {
    return(
      data.frame(
        y = 10,
        ymin = 8,
        ymax = 15
      )
    )
  }
)

dev.off()

# representing uncertainty ########################

# functions returning y, ymin, and ymax can be used to represent uncertainty

# Let's create some fake data again:
x <- rep(1:20, each = 100)
y <- 3*sqrt(x) + rnorm(length(x))
df <- data.frame(x = x, y = y)
plot.base <- ggplot(
  data = df,
  mapping = aes(
    x = x,
    y = y
  )
) + geom_point(alpha = 0.1)
plot(plot.base)

# We've seen how geom_smooth can give us a line of best fit with a confidence
# region. But what if we want to compute the confidence region ourselves?
plot.base + geom_smooth()

plot.base +
  stat_summary(
    geom = 'ribbon',
    fun.data = function(x) {
      data.frame(
        y = mean(x),
        ymin = mean(x) - sd(x),
        ymax = mean(x) + sd(x)
      )
    },
    alpha = 0.2
  ) +
  stat_summary(
    geom = 'line',
    fun = mean,
    colour = 'blue'
  )

# Nonetheless, geom_smooth is quite powerful on its own. For example, it can do
# logistic regression and correctly compute the exact confidence interval (i.e.,
# not using a normal approximation)

x <- seq(-6, 6, length.out = 100)
y <- (runif(100) < (1 / (1 + exp(-x)))) + 0
df <- data.frame(
  x = x,
  y = y
)
qplot(x, y, data = df) # Quick visualization

ggplot(
  data = df,
  mapping = aes(
    x = x,
    y = y
  )
) + 
  geom_point() + 
  geom_smooth(
    method = glm,
    formula = y ~ x,
    method.args = list(family = binomial)
  )

dev.off()

# Saving your figure ########################

# Let's create a plot we want to save
img <- ggplot(
  data = mpg,
  mapping = aes(
    x = hwy,
    y = cty
  )
) + geom_point() +
  facet_wrap(vars(class)) +
  labs(
    x = 'Highway MPG',
    y = 'City MPG'
  )
print(img)

# The ggsave() function will save it for us
ggsave(
  filename = 'plot.jpg',
  plot = img
)

# Resized:
ggsave(
  filename = 'plot.jpg',
  plot = img,
  width = 6,
  height = 6,
  units = 'in'
)

# Without compression:
ggsave(
  filename = 'plot.png',
  plot = img,
  width = 6,
  height = 6,
  units = 'in'
)

# As vector:
ggsave(
  filename = 'plot.svg',
  plot = img,
  width = 6,
  height = 6,
  units = 'in'
)

# As PDF:
ggsave(
  filename = 'plot.pdf',
  plot = img,
  width = 6,
  height = 6,
  units = 'in'
)

# Happy plotting! I can be reached at kinleyid@mcmaster.ca if you have
# questions.

dev.off()