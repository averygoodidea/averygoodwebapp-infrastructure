const crypto = require('crypto')
const algorithm = 'aes-256-cbc'
const key = crypto.randomBytes(32)
const iv = crypto.randomBytes(16)
const AWS = require('aws-sdk')
const sesClient = new AWS.SES()
const moment = require('moment')

// for more info about encrypt and decrypt functions, please visit:
// - https://codeforgeek.com/encrypt-and-decrypt-data-in-node-js/

const encrypt = (data, hoursUntilExpiration) => {
    const cipher = crypto.createCipheriv(algorithm, Buffer.from(key), iv)
    const dataToEncrypt = { data }
    if (hoursUntilExpiration) {
        dataToEncrypt.expiresAt = moment().add(hoursUntilExpiration, 'hours').format()
    }
    let encrypted = cipher.update(JSON.stringify(dataToEncrypt))
    encrypted = Buffer.concat([encrypted, cipher.final()])
    return { a: iv.toString('hex'), b: encrypted.toString('hex'), c: key.toString('hex')}
}

const decrypt = data => {
    const iv = Buffer.from(data.a, 'hex')
    const encryptedText = Buffer.from(data.b, 'hex')
    const key = Buffer.from(data.c, 'hex')
    let decipher = crypto.createDecipheriv(algorithm, key, iv)
    let decrypted = decipher.setAutoPadding(false)
    decrypted = decipher.update(encryptedText)
    decrypted = Buffer.concat([decrypted, decipher.final()])
    decrypted = convertToJson(decrypted)
    let result
    if (decrypted.expiresAt) {
        const now = moment().format()
        const expiresAt = moment(decrypted.expiresAt).format()
        result = moment(now).isBefore(expiresAt) ? decrypted.data : 'this hash has expired'
    } else {
        result = decrypted.data
    }
    return result
}

const convertToJson = data => {
    // remove pesky trailing unicode characters that the Buffer Class adds to this decrypted string
    const pieces = data.toString().split('}')
    let str = ''
    for (let i = 0; i < pieces.length - 1; i++) {
        str += pieces[i] + '}'
    }
    // yes, JSON needs to be parsed twice due to the stringifying of a string
    return JSON.parse(JSON.parse(JSON.stringify(str)))
}

const sendMagicLink = (data, callback) => {
    const { magicLink } = data
    const emailData = {
        Source: data.from,
        Destination: {
            ToAddresses: [data.to]
        },
        Message: {
            Subject: {
                Data: data.subject //data.subject
            },
            Body: {
                Html: {
                    Data: `<p>${data.body}</p><p>${magicLink}</p>`, //data.body,
                    Charset: 'utf8'
                }
            }
        }
    }
    sesClient.sendEmail(emailData, callback)
}

module.exports = {
	encrypt,
	decrypt,
    sendMagicLink
}