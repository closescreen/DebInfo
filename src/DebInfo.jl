module DebInfo

export debinfofun
debinfofun(on::Bool) = on ? (x...)->info(x...) : (x...)->nothing

export statinfofun
statinfofun(on::Bool) = on ? (x...)->info(x...) : (x...)->nothing

type ProgressBar
 io::IO
 start_msg::AbstractString
 step::Int
 step_str::AbstractString
 veha::Int
 veha_fun::Function
 cnt::BigInt
 enabled::Bool
end
export ProgressBar


""" progressbar = Progressbar(STDERR, "Progress started:", 10, ".", 100, (cnt)->"[\$cnt]" ) """
ProgressBar( io::IO, start_msg::AbstractString, step::Int, step_str::AbstractString, veha::Int, veha_fun::Function; enabled::Bool=true ) =
    ProgressBar( io, start_msg, step, step_str, veha, veha_fun, 0, enabled )

""" progressbar = Progressbar( "Progress started:", 10, ".", 100, (cnt)->"[\$cnt]" ) """
ProgressBar( start_msg::AbstractString, step::Int, step_str::AbstractString, veha::Int, veha_fun::Function; enabled::Bool=true ) =
    ProgressBar( STDERR, start_msg, step, step_str, veha, veha_fun, 0, enabled )


""" progressbar = ProgressBar(STDERR, "Progess:", 10=>"-", 100=>"100") """
ProgressBar{I<:Int,S<:AbstractString}( io::IO, start_msg::AbstractString, step_and_str::Pair{I,S}, veha_and_str::Pair{I,S}; enabled::Bool=true) = 
 ProgressBar( io, start_msg, step_and_str..., veha_and_str[1], (cnt)->veha_and_str[2], 0, enabled)

""" progressbar = ProgressBar( "Progess:", 10=>"-", 100=>"100") """
ProgressBar{I<:Int,S<:AbstractString}( start_msg::AbstractString, step_and_str::Pair{I,S}, veha_and_str::Pair{I,S}; enabled::Bool=true) = 
 ProgressBar( STDERR, start_msg, step_and_str..., veha_and_str[1], (cnt)->veha_and_str[2], 0, enabled)


""" progressbar = Progressbar(STDERR, "Progress started:", 10=>".", 100=>(n)->"[\$n]" ) """    
ProgressBar{I<:Int,S<:AbstractString}( io::IO, start_msg::AbstractString, step_and_str::Pair{I,S}, veha_and_fun::Pair; enabled::Bool=true) = 
 ProgressBar( io::IO, start_msg, step_and_str..., veha_and_fun..., 0, enabled)

""" progressbar = Progressbar( "Progress started:", 10=>".", 100=>(n)->"[\$n]" ) """    
ProgressBar{I<:Int,S<:AbstractString}( start_msg::AbstractString, step_and_str::Pair{I,S}, veha_and_fun::Pair; enabled::Bool=true) = 
 ProgressBar( STDERR, start_msg, step_and_str..., veha_and_fun..., 0, enabled)


"""
using DebInfo

progressbar = ProgressBar(\"|\",1=>\"#\",10=>n->"[\$n]")
DebInfo.ProgressBar(\"|\",1,\"#\",10,#1,0)

for i in 1:100 goprogress(progressbar) end
|########[10]#########[20]#########[30]#########[40]#########[50]#########[60]#########[70]#########[80]#########[90]#########[100]
"""
function goprogress(p::ProgressBar)
 if p.cnt==0 
  p.enabled && print( p.io, p.start_msg)
  p.cnt+=1
 else
  p.cnt+=1
  if p.cnt % p.veha == 0
   p.enabled && print( p.io, p.veha_fun(p.cnt))
  elseif p.cnt % p.step == 0
   p.enabled && print( p.io, p.step_str)
  end
 end
 p.cnt
end
export goprogress

""" 
progressbar = ProgressBar(\"|\",1=>\"#\",10=>n->\"[\$n]\")

advans::Function = go(progressbar) # returns ()->goprogress(progressbar)

for i in 1:100 advans() end
"""
go(p::ProgressBar)=()->goprogress(p)
export go


""" ok(progressbar) 

ok(progressbar , \"Success!\") 

n>5 ? ok(progressbar) : err(progressbar)
"""
ok(p::ProgressBar, msg::AbstractString="[ok]") = p.enabled && print_with_color(:green, p.io, msg)
export ok

""" err(progressbar)

err(progressbar, \"something wrong...\") """
err(p::ProgressBar, msg::AbstractString="[error]") = p.enabled && print_with_color(:red, p.io, msg)
export err


""" reset_progress( progressbar)

OR

reset_progress( progressbar, \"try again:\")
"""
reset_progress(p::ProgressBar, new_start_msg::AbstractString) = ( p.start_msg = new_start_msg; p.cnt=0; nothing )
reset_progress(p::ProgressBar) = (p.cnt=0; nothing)
export reset_progress

""" disable( p::ProgressBar) = p.enabled=false """
disable( p::ProgressBar) = p.enabled=false


""" enable( progressbar ) """
enable(p::ProgressBar) = p.enabled=true


"""
julia> infoiter( x->x*2, [1,2,3], ()->print(STDERR,\"#\") ) |>collect
###3-element Array{Int64,1}:
 2
 4
 6
"""
function infoiter( pred::Function, initer, foreachfun::Function )
 ( begin rv=pred(el); foreachfun(); rv end for el in initer )
end
export infoiter

function infoiter( pred::Function, filterin::Function, initer, foreachfun::Function )
 ( begin rv=pred(el); foreachfun(); rv end for el in filter( filterin, initer) )
end


#""" [1,2,3] |> infoiter(x->x*2, ()->print(STDERR,\"#\")) 
#
#OR
#
#julia> progressbar = ProgressBar( \"|\", 1=>\"-\", 5=>n->\"|\$n|\" )
#
#julia> 1:20|> infoiter( x->x*2, go(progressbar) )|>collect;
#
#|---|5|----|10|----|15|----|20|
#
#"""
#infoiter( pred::Function, foreachfun::Function ) = initer->infoiter( pred, initer, foreachfun )

"""
julia> infoiter( x->x*2, [1,2,3], \"Iter A\") |>collect
INFO: Iter A In: 1
INFO: Iter A Out: 2
INFO: Iter A In: 2
INFO: Iter A Out: 4
INFO: Iter A In: 3
INFO: Iter A Out: 6
3-element Array{Int64,1}:
 2
 4
 6
"""
function infoiter( pred::Function, filterin::Function, initer, debugprefix::AbstractString )
 ( begin info( "$debugprefix In: $el" ); rv=pred(el); info( "$debugprefix Out: $rv"); rv end for el in filter( filterin, initer) )
end

function infoiter( pred::Function, initer, debugprefix::AbstractString )
 ( begin info( "$debugprefix In: $el" ); rv=pred(el); info( "$debugprefix Out: $rv"); rv end for el in initer )
end


""" [1,2,3] |> infoiter(x->x*2, \"Iter A\") """
infoiter( pred::Function, debugprefix::AbstractString ) = initer->infoiter( pred, initer, debugprefix )

infoiter( pred::Function, filterin::Function, debugprefix::AbstractString ) = initer->infoiter( pred, filter( filterin, initer), debugprefix )


""" infoiter( x->x*2, [1,2,3]) # without any debug/info """
infoiter(  pred::Function, initer) = (pred(i) for i in initer)

infoiter(  pred::Function, filterin::Function, initer) = (pred(i) for i in filter( filterin, initer))



""" [1,2,3] |> infoiter(x->x*2) # without any debug/info """
infoiter( pred::Function) = initer->infoiter( pred, initer)

infoiter( pred::Function, filterin::Function) = initer->infoiter( pred, filter( filterin, iter))


end # module










