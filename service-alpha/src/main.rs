fn main() {
    let mut counter = 0;
    loop {
        println!("Hello from Service Alpha! I handle incoming API requests. Counter: {}", counter);
        counter += 1;
        std::thread::sleep(std::time::Duration::from_secs(5));
        if counter >= 20 {
            break;
        }
    }
    println!("Hello from Service Alpha! I handle incoming API requests.1111");

    println!("Hello from Service Alpha! I handle incoming API requests.");
}
