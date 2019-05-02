#Import mpo data. This may require customization based on the directory to the file that I title mpo.csv. 
run = function(strict) {
  library(readr)
  mpo_data<-data.frame(read_csv("~/Downloads/mpo.csv", col_names = TRUE))
  mpo_data$MPO = round(mpo_data$MPO, digits=0)
  #Frequency table
  d = aggregate(mpo_data$MPO,list(mpo_data$Utility),FUN=table)
  pmf = interpolate(d)
  analyze(pmf, strict)
}

#Parameters for analysis
utilities = c("West Bengal","Gujarat",	"Eastern","Chamundeshwari", "Uttarakhand","Southern","Chattisgarh","Northern")
z_scores = list(0.0061,0.0825,0.4598,0.6528,0.6529,0.6805,0.7772,0.9580)
names(z_scores) = utilities
p_cf_x = 0.0267
monthly_debt_service = 624700000/12
ratings = c(0.008,.048,.057,.131,0.218,0.404)
rating_symbols = c("AA","A","BBB","BB","B","C")


#determine PSM sizing requirements and eligibility for all utilities based on parameters for analysis
analyze = function(pmf, approxbool) {
  results = list()
  par(mfrow=c(3,3))
  for(utility in utilities) {
    y = c()
    for(rating in ratings) {
        coverage = pdef_psm(utility,rating,approxbool)
        y=append(y,coverage)
    }
    results[[utility]] = y
    if(all(is.na(y))) {
      print(paste(utility," does not have any conditions for PSM to reduce risk."))
      next
    }
    barplot(y,xlab = "Ratings", ylab = "# Months Guarantee", main = paste("PSM Size -",utility), names.arg=ratings)
  }
  convert_inr = function(x) x*monthly_debt_service
  results = as.data.frame(sapply(results,FUN=convert_inr))
  results = cbind(results,ratings,rating_symbols)
  print(results)
  return(results)
}

#compute probability of default with and without PSM

pdef = function(utility) {
  z_score = z_scores[[utility]]
  p_default = (z_score + (1-z_score) * p_cf_x)
  print(p_default)
  return(p_default)
}

#function takes the name of utility, bond rating p of default, approx boolean which if true finds min PSM size to satisfy needs. If false determines most approximate size.)
pdef_psm = function(utility, rating_p, approxbool) {
  if(missing(approxbool)) {
    approxbool = FALSE
  }
  z_score = z_scores[[utility]]
  security_p = (rating_p - (1-z_score)*p_cf_x)/z_score
  if(security_p > 0 && security_p < 1) {
    security_p = 1-security_p
    delta=pmf[[utility]][,3]-security_p
    if(approxbool == FALSE){
      s = pmf[[utility]][which(delta==min(delta[delta>0])),1]
    } 
    else {
      s = pmf[[utility]][which.min(abs(delta)),1]
    }
  print(pmf[[utility]][,3])
    return(s)
  }
  else {
    print(paste("Z-score default probability is too large to meet bond rating. PSM cannot offset.",security_p))
    s=NA
    return(s)
  }
}

# Creating frequency linear interpolations based on mpo, range is minimum MPO to maximum. 

interpolate = function(d){
  l = list()
  print(d)
  for (i in 1:length(d[[2]])) {
    df = as.data.frame(d[[2]][i])
    df[,1]= as.numeric(as.vector.factor(df[,1]))
    mpo = df[,1]
    freq = df[,2]
    v=as.data.frame(approx(x=mpo,y=freq,n=(max(mpo)-min(mpo)+1)))
    v[,2]=v[,2]/sum(v[,2])
    print(v) #printflag
    v[,3]=cumsum(v[,2])
    l[[i]]=v
    names(l)[i]=d[i,1]
  }
  return(l)
}

#
run(strict = FALSE)
