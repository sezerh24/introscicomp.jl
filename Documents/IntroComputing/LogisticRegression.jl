using Flux, Statistics, MLDatasets, DataFrames, OneHotArrays

const classes = ["Iris-setosa", "Iris-versicolor", "Iris-virginica"];

Iris()
x, y = Iris(as_df=false)[:];

typeof(x)

x = Float32.(x)
y = vec(y)
custom_y_onehot = unique(y) .== permutedims(y)
flux_y_onehot = onehotbatch(y, classes)
# logistic regression 
m(W, b, x) = W*x .+ b

W = rand(Float32,3,4)
b = [0.0f0, 0.0f0, 0.0f0]
custom_softmax(x) = exp.(x) ./ sum(exp.(x), dims=1)

custom_model(W, b, x) = m(W, b, x) |> custom_softmax

all(0 .<= custom_model(W, b, x) .<= 1)

sum(custom_model(W, b, x), dims=1)

flux_model = Chain(Dense(4 => 3), softmax)

flux_model[1].weight
flux_model[1].bias

custom_logitcrossentropy(ŷ, y) = mean(.-sum(y .* logsoftmax(ŷ; dims = 1); dims = 1));

function custom_loss(W, b, x, y)
    ŷ = custom_model(W, b, x)
    custom_logitcrossentropy(ŷ, y)
end

function flux_loss(flux_model, x, y)
    ŷ = flux_model(x)
    Flux.logitcrossentropy(ŷ, y)
end
flux_loss(flux_model, x, flux_y_onehot)

custom_loss(W, b, x, custom_y_onehot)
argmax(custom_y_onehot, dims=1)  # calculate the cartesian index of max element column-wise
max_idx = [x[1] for x in argmax(custom_y_onehot; dims=1)]

function custom_onecold(custom_y_onehot)
    max_idx = [x[1] for x in argmax(custom_y_onehot; dims=1)]
    vec(classes[max_idx])
end

custom_onecold(custom_y_onehot)

istrue = Flux.onecold(flux_y_onehot, classes) .== custom_onecold(custom_y_onehot);

all(istrue)

custom_accuracy(W, b, x, y) = mean(custom_onecold(custom_model(W, b, x)) .== y);
custom_accuracy(W, b, x, y)

flux_accuracy(x, y) = mean(Flux.onecold(flux_model(x), classes) .== y);

flux_accuracy(x, y)

dLdW, dLdb, _, _ = gradient(custom_loss, W, b, x, custom_y_onehot)

W .= W .- 0.1 .* dLdW
b .= b .- 0.1 .* dLdb

custom_loss(W, b, x, custom_y_onehot)

function train_custom_model()
    dLdW, dLdb, _, _ = gradient(custom_loss, W, b, x, custom_y_onehot)
    W .= W .- 0.1 .* dLdW
    b .= b .- 0.1 .* dLdb
end

for i = 1:500
    train_custom_model();
    custom_accuracy(W, b, x, y) >= 0.98 && break
end

custom_accuracy(W, b, x, y)

custom_loss(W, b, x, custom_y_onehot)

flux_loss(flux_model, x, flux_y_onehot)

function train_flux_model()
    dLdm, _, _ = gradient(flux_loss, flux_model, x, flux_y_onehot)
    @. flux_model[1].weight = flux_model[1].weight - 0.1 * dLdm[:layers][1][:weight]
    @. flux_model[1].bias = flux_model[1].bias - 0.1 * dLdm[:layers][1][:bias]
end

for i = 1:500
    train_flux_model();
    flux_accuracy(x, y) >= 0.98 && break
end


@show flux_accuracy(x, y);

flux_loss(flux_model, x, flux_y_onehot)
