import re

def main():
    driver = []
    monitor = []
    with open("measurement.log", "r") as file:
        for line in file.readlines():
            driver_match = re.match(r"Drv cycles: ([0-9]+)", line) # , ([0-9]+)
            if driver_match:
                driver.append(int(driver_match.group(1)))
            monitor_match = re.match(r"Mon cycles: ([0-9]+)", line) # , ([0-9]+)
            if monitor_match:
                monitor.append(int(monitor_match.group(1)))
    print(driver)
    print(monitor)
    latency = [(monitor[i] - driver[i]) * 4 / 1000 for i in range(len(monitor))]
    throughput = 4096 * len(monitor) / ((monitor[-1] - monitor[0]) * 4)
    print(latency)
    print(throughput)

if __name__ == "__main__":
    main()
