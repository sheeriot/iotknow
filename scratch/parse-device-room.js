tags = ['one','two','ubi-device-room']

for(var key in tags) {
        var tag = tags[key]
        if (tag.startsWith('ubi-')) {
            devroom = tag.substring(4)
            var [dev, room] = devroom.split('-') // Splitting devroom by hyphen
            // console.log(devroom)
            console.log(dev + ':' + room)
    }
}