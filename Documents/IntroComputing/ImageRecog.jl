using CSV
using DataFrames

train_data_input = CSV.read("csvTrainImages 13440x1024.csv", DataFrame)
test_data_input = CSV.read("csvTestImages 3360x1024.csv", DataFrame)

train_label_input = CSV.read("csvTrainLabel 13440x1.csv", DataFrame)
test_label_input = CSV.read("csvTestLabel 3360x1.csv", DataFrame)


using MLDataPattern:shuffleobs,splitobs
using Flux: onehotbatch, DataLoader
using Plots
using Images


train_data = reshape(Array(train_data_input),:,32,32)/255;
test_data = reshape(Array(test_data_input),:,32,32)/255;
train_data = reverse(train_data,dims=(2));
test_data = reverse(test_data,dims=(2));



