const createUrl = (method = 'addNote', params = {}) => [
    'noteplan://x-callback-url/',
    method,
    '?',
    (new URLSearchParams(params)).toString()
].join('')

/**
 * Generates an openNote callback for the calendar type notes
 * 
 * @param {String} filename format `YYYYmmdd.md` or alternative
 * @param {Boolean} sameWindow use the already open noteplan window?
 * @returns string
 */
const createCalendarNoteUrl = (filename, sameWindow = true) => {
    return createUrl('openNote', {
        noteDate: filename.split('.').pop(),
        useExistingSubWindow: sameWindow ? 'yes' : 'no'
    })
}

/**
 * Generates an openNote callback for the note notes
 * 
 * @param {String} filename format `YYYYmmdd.md` or alternative
 * @param {Boolean} sameWindow use the already open noteplan window?
 * @returns string
 */
const createOpenNoteUrl = (filename, sameWindow = true) => {
    return createUrl('openNote', {
        filename: filename,
        useExistingSubWindow: sameWindow ? 'yes' : 'no'
    })    
}
const createAddNoteUrl = (title, body) => {}

module.exports = {
    createUrl,
    createCalendarNoteUrl, createOpenNoteUrl,
    createAddNoteUrl
}