const fs = require('fs-extra')
const src = `${__dirname}/src`
const tmp = `${__dirname}/tmp`
const FileType = require('file-type')
const renameFiles = (filesToBeUploaded, updatedFilenames, cb) => {
	//console.log('A')
	const renamedFilenameDataMap = {}
	new Promise( (resolve, reject) => {
		// index source directory
		// index images names to be uploaded
		// for each image name to be uploaded
			// loop through source directory
				// does this file name match the image name?
					// if so
						// copy this file over to the tmp directory and give it the new name that corresponds to this image name
					// when all the files have been copied and renamed
						// return an object that contains a new image name to data map
		fs.readdir(src, (err, filenames) => {
			if (err) {
				//console.log('B', err)
				reject(err)
				return
		    }
	 		//console.log('C', filenames)
	 		let itemsCopied = 0
	 		filesToBeUploaded.forEach( (key, i) => {
		        filenames.forEach( filename => {
		        	if (filename === key) {
		        		fs.copySync(`${src}/${filename}`, `${tmp}/${updatedFilenames[i]}`)
		        		itemsCopied++
		        	}
		        	if(itemsCopied === filesToBeUploaded.length) {
		        		//console.log('D', filesToBeUploaded)
		        		resolve()
		        	}
		        })
	 		})
	    })
	}).then( async () => {
		//console.log('E')
		for (let i = 0; i < updatedFilenames.length; i++) {
			const filename = updatedFilenames[i]
			const buffer = fs.readFileSync(`${tmp}/${filename}`)
			const { mime:type } = await FileType.fromFile(`${tmp}/${filename}`)
			renamedFilenameDataMap[filename] = {
				buffer,
				type
			}
		}
		//console.log('F')
		cb(renamedFilenameDataMap)
	})
}
const resetFiles = cb => {
	// delete the tmp directory so no photos are retained
	fs.remove(tmp, err => {
		if (err) {
			return console.error(err)
		}
		cb && cb()
	})
}
module.exports = {
	resetFiles,
	renameFiles,
	paths: {
		tmp
	}
}