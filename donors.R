library(data.table)
library(dplyr)

# read in gofundme page data copied into excel, downloaded as csv
raw_data <- read.csv('~/Downloads/donors\ -\ Sheet1.csv', header = F)
colnames(raw_data) <- c('raw')
View(raw_data)

donors <- data.table(raw_data)
# row id
donors[, raw := as.character(raw)]
# row type
donors[, type := ifelse(grepl('donated ', raw), 'donor',
                      ifelse(grepl('Private: ', raw), 'anonymous',
                             ifelse(grepl('Referred ', raw), 'referred',
                                    ifelse(!grepl('thank', raw, ignore.case = TRUE) 
                                           & nchar(raw) > 2, 'comment',
                                           'none'))))]
donors <- donors[type != 'none', ]
# group together rows by donor, 
# i.e., each new donor has a new group
# their anonymous status, referral, and thanked status will all have the same group number
donors[, group := ifelse(type == 'donor', 1, 0)]
donors[, group := cumsum(group)]

# collapse each record to 1 row
donors <- donors[, lapply(.SD, paste0, collapse = '·'), by = group]

# split donor and amount they donated into separate cols
donors[, split1 := strsplit(raw, 'donated \\$')]
donors[, name := sapply(split1, function(l) substr(l[[1]], 1, nchar(l[[1]]) - 1))]

donors[, split1_1 := sapply(split1, function(l) l[[2]])]
donors[, split2 := strsplit(split1_1, '·')]
donors[, amount := sapply(split2, function(l) as.numeric(l[[1]]))]
donors[, day := sapply(split2, function(l) l[[2]])]
donors[, day := ifelse(grepl('hr', day), 0,
                       ifelse(grepl('d', day), substr(day, 1, nchar(day) - 2), NaN))]
day_max <- max(donors$day)
donors[, day := as.numeric(day_max) - as.numeric(day)]

# split referral into new column
donors[, split2_1 := sapply(split2, function(l) ifelse(length(l) > 2, l[[3]], ''))]
donors[, split3 := strsplit(split2_1, 'Referred by ')]
donors[, referred_by := sapply(split3, function(l) ifelse(length(l) > 1, l[[2]], ''))]

# one hot encode whether they are anonymous and/or commented
donors[, anonymous := grepl('anonymous', type)]
donors[, comment := grepl('comment', type)]

# drop unnecessary cols
cols_to_drop <- colnames(donors)[grepl('split', colnames(donors))]
cols_to_drop <- c(cols_to_drop, 'group', 'raw', 'type')
cols_to_keep <- setdiff(colnames(donors), cols_to_drop)
donors <- donors[, ..cols_to_keep]

# what order they were in the donations
donors[, donation_order := nrow(donors) + 1 - as.numeric(row.names(donors))]

View(donors)

h <- hist(donors$amount
     , col = 'lightblue'
     , breaks = seq(0,250,5)
     , xlab = 'Amount ($)', main = 'Histogram of amount donated')

plot(donors$donation_order, donors$amount
     , type = 'l', col = 'darkblue'
     , xlab = 'Donation order', ylab = 'Amount ($)', main = 'Amount donated by time')

tab <- table(donors$day)
tab
hist(donors$day 
     , col = 'lightblue', breaks = c(0:5) - 0.5
     , xlab = 'Day', main = 'Histogram of number of donations')

boxplot(amount ~ day, data = donors
        , col = 'lightblue', names = paste0(names(tab), ' (n = ', tab, ')')
        , xlab = 'Day', ylab = 'Amount ($)' , main = 'Distributrion of amount donated')

by_day_sum <- donors[, .(day, amount)][, lapply(.SD, sum), by = day][order(day),]
by_day_mean <- donors[, .(day, amount)][, lapply(.SD, mean), by = day][order(day),]
by_day_median <- donors[, .(day, amount)][, lapply(.SD, median), by = day][order(day),]
mp <- barplot(by_day_sum$amount
        , col = 'lightblue'
        , names.arg = by_day_sum$day
        , xlab = 'Donation day', ylab = 'Amount ($)', main = 'Amount donated by day')
lines(mp, by_day_mean$amount, col = 'darkblue')
lines(mp, by_day_median$amount, col = 'darkred')
legend('topright', c('Sum', 'Mean', 'Median')
       , fill = c('lightblue', 'darkblue', 'darkred'), col = c('lightblue', 'darkblue', 'darkred'))

tab <- table(donors$anonymous)
tab
bp <- boxplot(amount ~ anonymous, data = donors
        , col = 'lightblue', names = paste0(names(tab), ' (n = ', tab, ')')
        , xlab = 'Anonymous?', ylab = 'Amount ($)' , main = 'Distributrion of amount donated')

tab <- table(donors$comment)
tab
bp <- boxplot(amount ~ comment, data = donors
        , col = 'lightblue', names = paste0(names(tab), ' (n = ', tab, ')')
        , xlab = 'Comment?', ylab = 'Amount ($)' , main = 'Distributrion of amount donated')

tab <- table(donors$referred_by)
tab
aggregate(donors$amount, list(donors$referred_by), mean)
aggregate(donors$amount, list(donors$referred_by), median)
boxplot(amount ~ referred_by, data = donors
        , col = 'lightblue', names = paste0(names(tab), ' (n = ', tab, ')')
        , xlab = 'Referred by', ylab = 'Amount ($)', main = 'Distribution of amount donated')

