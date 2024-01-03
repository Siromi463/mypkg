import rclpy
from rclpy.node import Node
from std_msgs.msg import Int16
import threading

timer = None

def listener_callback(msg):
    global timer
    hex_value = format(msg.data, '04x')
    print('Received value: %d, Hex: %s' % (msg.data, hex_value))
    if timer is not None:
        timer.cancel()
    timer = threading.Timer(10.0, rclpy.shutdown)
    timer.start()

def main():
    global timer
    rclpy.init()
    node = rclpy.create_node('converter_tohex')
    subscription = node.create_subscription(
        Int16,
        'chatter',
        listener_callback,
        10)
    timer = threading.Timer(10.0, rclpy.shutdown)
    timer.start()
    rclpy.spin(node)

if __name__ == '__main__':
    main()
