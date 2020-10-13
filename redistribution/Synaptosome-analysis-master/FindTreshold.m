function [treshold] = FindTreshold(data, ndata, step)
%This function searches treshold such that number of elements from data 
%larger than treshold, should be close to ndata
ind=0;
i=0;
while ind==0 & i<max(data)/step
    
    treshold = i*step;
    newdata = data>treshold;
    if sum(newdata)<ndata ind=1; end
    i=i+1;
end
end

