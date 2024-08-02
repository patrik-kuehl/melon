export function sleep(milliseconds) {
    const until = new Date(new Date().getTime() + milliseconds)

    while (until > new Date()) {}
}
