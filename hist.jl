# Histogram of an image I

function hist(I::Float32, nbins)
	a, b = extrema(I)	# values range
	binsize = (b - a) / nbins + eps(Float32)
	println("min $min max $max binsize $binsize")
	
	h = zeros(Int, nbins)
	map(x->h[trunc(Int, (x-a)/binsize)+1]+=1, I) # Build histogram
	n = length(I)
	nh = map(x-> Float32(x)/n, h) # normalized histogram pdf
	ncs = cumsum(nh)	# Normalized Histogram Cumulative Sum
	output = round(ncs[i]*levels)
	return ncs
end

# Cumulative Distribution function
function cdf(I)
	for i in 1:nh
		normalized_cumulsum += InputIm_normalized_histogram(i)
		ncs[i] = normalized_cumulsum
		output[i] = round(ncs[i]*levels)  #formula: (L-1)*cdf
	end
	# Mapping of the original gray level to the new one
	for i in I
		for j=1:size(InputIm,2)
		      OutputIm(i,j) = output(InputIm(i,j)+1);       
		  end
	end
end
