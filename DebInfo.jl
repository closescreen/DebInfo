module DebInfo

export debinfofun
debinfofun(on::Bool) = on ? (x...)->info(x...) : (x...)->nothing

export statinfofun
statinfofun(on::Bool) = on ? (x...)->info(x...) : (x...)->nothing

type ProgressBar
 start_msg::AbstractString
 step::Int
 step_str::AbstractString
 veha::Int
 veha_fun::Function
 cnt::BigInt
end
export ProgressBar

""" progressbar = Progressbar("Progress started:", 10, ".", 100, (cnt)->"[\$cnt]" ) """
ProgressBar( start_msg::AbstractString, step::Int, step_str::AbstractString, veha::Int, veha_fun::Function ) =
    ProgressBar( start_msg, step, step_str, veha, veha_fun, 0 )

""" progressbar = ProgressBar("Progess:", 10=>"-", 100=>"100") """
ProgressBar{I<:Int,S<:AbstractString}( start_msg::AbstractString, step_and_str::Pair{I,S}, veha_and_str::Pair{I,S}) = 
 ProgressBar( start_msg, step_and_str..., veha_and_str[1], (cnt)->veha_and_str[2], 0)

""" progressbar = Progressbar("Progress started:", 10=>".", 100=>(n)->"[\$n]" ) """    
ProgressBar{I<:Int,S<:AbstractString}( start_msg::AbstractString, step_and_str::Pair{I,S}, veha_and_fun::Pair) = 
 ProgressBar( start_msg, step_and_str..., veha_and_fun..., 0)

"""
using DebInfo

progressbar = ProgressBar("|",1=>"#",10=>n->"[\$n]")
DebInfo.ProgressBar("|",1,"#",10,#1,0)

for i in 1:100 goprogress(progressbar) end
|########[10]#########[20]#########[30]#########[40]#########[50]#########[60]#########[70]#########[80]#########[90]#########[100]
"""
function go(p::ProgressBar)
 if p.cnt==0 
  write(STDERR, p.start_msg)
  p.cnt+=1
 else
  p.cnt+=1
  if p.cnt % p.veha == 0
   write(STDERR, p.veha_fun(p.cnt))
  elseif p.cnt % p.step == 0
   write(STDERR, p.step_str)
  end
 end
 p.cnt
end
export go

"Alias for go(...) function"
const goprogress = go
export goprogress


end # module