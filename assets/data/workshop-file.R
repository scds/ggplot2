
### Atomic data types

# Numbers
x <- 1
# arithmetic
x + 1 # addition
x - 1 # subtraction
x * 2 # multiplication
x / 2 # division
x ** 2 # exponentiation
1 / (2 - 0.5) # BEDMAS rules

# Text (strings)
greeting <- "hello"
greeting <- 'hello'
sentence <- 'He says "hello"'
sentence <- "I'm busy now"

# Booleans (true/false values)
bool1 <- FALSE
bool2 <- TRUE

# Booleans as a result of comparisons
x <- 2
y <- 3
x < y
x <= y
x > y
x >= y
x == y # Equal
x != y # Not equal

# Boolean operators
x <- TRUE
y <- FALSE
x & y # and
x | y # or
!y # not

# Order of operations with Booleans

# NOTE: the example used in the workshop was incorrect---the result did not
# differ for different orders of operations. The following example illustrates
# the importance of order of operations:
# ------------------------------------------------------------------------------
# Suppose we want to know if we can publish our results. We can publish if the
# results are significant or the study was preregistered, and if we have the
# funds to publish open-access or the journal will waive open-access fee.
# Suppose we have the funds to publish open-access even though the journal won't
# waive the fee, but out results were not significant and the study was not
# preregistered. Let's create some variables to represent the situation:
funds <- TRUE # We have the funds
waive <- FALSE # The journal won't waive the fee
signif <- FALSE # Our results are not significant
prereg <- FALSE # Our study was not preregistered
# So, can we publish?
can_publish <- funds | waive & signif | prereg
print(can_publish)
# Surprisingly, the above expression says we can! Why is this? It's because the
# & operator takes precedence over the | operators, so it's evaluated first. The
# expression then reduces to TRUE | FALSE | FALSE, which evaluates to TRUE
# (regardless of which | operator is applied first). To ensure that the |
# operators are applied first, we should use brackets:
can_publish <- (funds | waive) & (signif | prereg)
print(can_publish)
# Now the result makes sense---we can't publish, but at least we know about
# Boolean order of operations!

# Collections (vectors)
x <- c(1, 2, 3, 4, 5)
y <- c(6, 7, 8)
z <- c(x, y)

a <- c()
b <- c(1, 2, 3)
d <- c(a, b)

a <- c(1, 2, 3, 'a', 'b', 'c') # Data types in vectors must all be the same
a <- c(first = 1, second = 2, third = 3)

# Accessing values in vectors
a[3]
a <- c(1, 2, 3, 4, 5)
a[3:5]
a[c(1, 2, 5)]

### Conditionals

p <- 0.009

if (p < 0.001) {
  print('Our results are very significant!')
} else if (p < 0.01) {
  print('Our results are fairly significant')
} else if (p < 0.05) {
  print('Our results are technically significant')
} else {
  print('Our results are not significant')
}

if (p < 0.001) {
  print('Our results are very significant!')
}
if (p < 0.01) {
  print('Our results are fairly significant')
}

### Loops

n_data <- 100
x <- rnorm(n_data)
y <- x + rnorm(n_data)

# Compute a single bootstrap correlation
n_sample <- 50
sample_idx <- sample(1:n_data, n_sample, replace = TRUE)
sampled_x <- x[sample_idx]
sampled_y <- y[sample_idx]
cor(sampled_x, sampled_y)

# Do bootstrapped correlations in a loop
n_iters <- 200
iter_count <- 0
cors <- c()
repeat {
  sample_idx <- sample(1:n_data, n_sample, replace = TRUE)
  sampled_x <- x[sample_idx]
  sampled_y <- y[sample_idx]
  curr_cor <- cor(sampled_x, sampled_y)
  cors <- c(cors, curr_cor)
  iter_count <- iter_count + 1
  if (iter_count == n_iters) {
    break
  }
}

iter_count <- 0
cors <- c()
while (iter_count < n_iters) {
  sample_idx <- sample(1:n_data, n_sample, replace = TRUE)
  sampled_x <- x[sample_idx]
  sampled_y <- y[sample_idx]
  curr_cor <- cor(sampled_x, sampled_y)
  cors <- c(cors, curr_cor)
  iter_count <- iter_count + 1
}

cors <- rep(NA, n_iters)
for (iter_count in 1:n_iters) {
  sample_idx <- sample(1:n_data, n_sample, replace = TRUE)
  sampled_x <- x[sample_idx]
  sampled_y <- y[sample_idx]
  curr_cor <- cor(sampled_x, sampled_y)
  cors[iter_count] <- curr_cor
}

# For loops example

data.file.names <- c(
  'data-file-1.csv',
  'data-file-2.csv',
  'data-file-3.csv',
  'data-file-4.csv',
  'data-file-5.csv'
)

cors <- c()
for (data.file.name in data.file.names) {
  data.file <- read.csv(data.file.name)
  cors <- c(cors, xycor(data.file))
}

### Functions

xycor <- function(df) {
  curr_cor <- cor(df$x, df$y)
  return(curr_cor)
}


