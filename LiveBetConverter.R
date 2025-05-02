library(implied)
library(dplyr)
library(odds.converter)

# Enter Value Needed
valueInDecPercent = .05

# Enter provided Odds
overOrAwayOdds = -139
underOrHomeOdds = -103



# Convert Entered Odds to no vig version
oddsUS <- c(overOrAwayOdds, underOrHomeOdds) 
oddsDec <- odds.us2dec(oddsUS)
noVig <- implied_probabilities(oddsDec, method = "wpo", normalize = TRUE)
noVigProbs <- noVig$probabilities

# Convert No Vig Probs to Fair Odds
# Convert to Fair Odds
fairOverOrAwayOdds <- round(odds.prob2us(noVigProbs[1]),0)
fairUnderOrHomeOdds <- round(odds.prob2us(noVigProbs[2]),0)

# Convert to Value Odds
valueOverOrAwayOdds <- round(odds.prob2us(noVigProbs[1] - valueInDecPercent),0)
valueUnderOrHomeOdds <- round(odds.prob2us(noVigProbs[2] - valueInDecPercent),0)




