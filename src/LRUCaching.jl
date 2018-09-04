module LRUCaching

import Base.show                                                                                                                                                                                          
export AbstractCache,
	   MemoryCache,
	   DiskCache,
	   @memcache

# Objects
# TODO (Corneliu): Add number of entries mechanism for DiskCache
abstract type AbstractCache end

struct MemoryCache{T<:Function, I, O} <: AbstractCache
	func::T
	cache::Dict{I, O}
end

struct DiskCache{T<:Function, S<:AbstractString} <: AbstractCache
	func::T
	cachefile::S
end


# Overload constructor
# TODO (Corneliu): Add DiskCache constructors
MemoryCache(f::T where T<:Function,
			T1::Type=Any,
			T2::Type=Any) = MemoryCache(f, Dict{T1, T2}())


# Call method
(mc::T where T<:MemoryCache)(args...; kwargs...) = begin
	_hashes = (map(hash, args)..., map(hash, collect(kwargs))...)
	if _hashes in keys(mc.cache)
		out = mc.cache[_hashes]
	else
		@info "Hash miss, caching hash=$_hashes..."
		out = mc.func(args...; kwargs...)
        mc.cache[_hashes] = out
    end
    return out
end


# Show method
show(io::IO, c::MemoryCache) = begin
	println(io, "Memory cache for \"$(c.func)\"")
	print(io, "`- [**memory**]: $(length(c.cache)) entries.")
end

show(io::IO, c::DiskCache) = begin
	println(io, "Disk cache for \"$(c.func)\"")
	print(io, "`- [$(c.file)]: ***(TODO)*** entries.")
end


# Macros

# Simple macro of the form:
# 	julia> foo(x) = x+1
# 	julia> fooc = @cache foo # now `fooc` is the cached version of `foo`
macro memcache(ex::Symbol)
	return esc(:(MemoryCache($ex)))
end  # macro


end  # module
