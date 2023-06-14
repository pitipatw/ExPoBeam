
println("count:", count)
while count < 10 
    println(count)
    global count += 1

end

function test3()
    println("start function")
    while count < 10 
        println(count)

        println(a)
        global count += 1
    end
    return count
end
