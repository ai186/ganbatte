label = createLabel(WIDTH / 2, HEIGHT / 4, "Translate こんいちは", 24)

print(getX(label))
print(getY(label))

b1 = createButton(getX(label) - 60, getY(label) + 80, "Hi", 12)
b2 = createButton(getX(label) + 60, getY(label) + 80, "Bye", 12)
b3 = createButton(getX(label) - 60, getY(label) + 160, "No", 12)
b4 = createButton(getX(label) + 60, getY(label) + 160, "Yes", 12)

add(label)
add(b1)
add(b2)
add(b3)
add(b4)


function onButtonPress(id)
    if getProperty(id, "text") == "Hi" then
        onCorrect()
    end
    print(getProperty(id, "text") .. " " .. id)
end


function onCorrect()
    remove(b1);
    remove(b2);
    remove(b3);
    remove(b4);
    nextLesson();
end