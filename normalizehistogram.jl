using BenchmarkTools, Base.Threads, Distributed
h, w = 60, 80
I = rand(Float32, h, w) .* 3.0f0 .+ 3.0f0;
rgb = 12f0 .* rand(Float32, 5000, 5000, 3) .+ 1.0f0;

"""
	extremadv(I::Array{Float32}) -> min, max

Find minimum and maximum values in I.
Similar to to extrema but 3x faster as de vectorized.
"""
function extremadv(I::Array{Float32})
    a = b = I[1]

    @inbounds for i = 2:length(I)
        if I[i] > b
            b = I[i]
        elseif I[i] < a
            a = I[i]
        end
    end

    return a, b
end

function normalizemap(I::Array{Float32,2})
    m1, m2 = extremadv(I)
    scale = 1 / (m2 - m1)
    J = Array{Float32,2}(undef, size(I))
    J = map(x -> (x - m1) * scale, I)
    return J
end

function normalizeloop(I::Array{Float32,2})
    m1, m2 = extremadv(I)
    scale = 1 / (m2 - m1)
    J = Array{Float32,2}(undef, size(I))
    for i = 1:length(I)
        @inbounds J[i] = (I[i] - m1) * scale
    end
    return J
end

function normalizeloopthreads(I::Array{Float32,2})
    m1, m2 = extremadv(I)
    scale = 1 / (m2 - m1)
    J = Array{Float32,2}(undef, size(I))
    @threads for i = 1:length(I)
        @inbounds J[i] = (I[i] - m1) * scale
    end
    return J
end

function normalizeloop!(I::Array{Float32,2})
    m1, m2 = extremadv(I)
    scale = 1 / (m2 - m1)
    for i = 1:length(I)
        @inbounds I[i] = (I[i] - m1) * scale
    end
end

function normalizecolorloop(rgb::Array{Float32,3})
    h, w, k = size(rgb)
    n = h * w
    for i = 1:3
        m1, m2 = extrema(rgb[:, :, i])
        a = m2 - m1
        #rgb[:, :, i] = (rgb[:, :, i] .- m1) ./ a
        for j = 1+(i-1)n:i*n
            rgb[j] = (rgb[j] - m1) / a
        end
    end
    return rgb
end

function normalizehistogram1(rgb::Array{Float32,3})
    h, w = size(I)
    @threads for i = 1:3
        m1, m2 = extrema(rgb[:, :, i])
        a = m2 - m1
        rgb[:, :, i] = (rgb[:, :, i] .- m1) ./ a
    end
    return rgb
end

function normalizehistogram2(rgb::Array{Float32,3})
    h, w = size(I)
    @spawnat 1 normalize(rgb[:, :, 1]),
    @spawnat 2 normalize(rgb[:, :, 2]), @spawnat 3 normalize(rgb[:, :, 3])

    return fetch(rgb)
end
