/**
 * This driver is a dummy driver for testing and developing kfuzz.
 *
 * DO NOT USE THIS IN PRODUCTION GOD DAMN IT!
 *
 * @author Florian Marrero Liestmann
 * @email f.m.liestmann@fx-ttr.de
 */
#include <linux/device.h>
#include <linux/fs.h>
#include <linux/kernel.h>
#include <linux/module.h>

#define MODULE_NAME "kfuzz"
#define DRV_DEV_NAME "kfuzz"
#define DRV_DEV_PATH "/dev/kfuzz"
#define IOCTL_CMD _IOR('v', '1', int32_t *)

static int device_open(struct inode *inode, struct file *file);
static long device_ioctl(struct file *file, unsigned int cmd,
                         unsigned long args);
static int device_release(struct inode *inode, struct file *file);

static struct class *class;
static int major_nr;
unsigned int *ops[3];
static struct file_operations fops = {.open = device_open,
                                      .release = device_release,
                                      .unlocked_ioctl = device_ioctl};

static int device_open(struct inode *inode, struct file *file) {
  printk(KERN_INFO "kfuzz: Opened device\n");

  return 0;
}

static long device_ioctl(struct file *file, unsigned int cmd,
                         unsigned long args) {
  char buf[256];
  struct ioctl_arg to;
  int res;

  switch (cmd) {
  case IOCTL_CMD:
    res = copy_from_user(&to, (int32_t *)arg, sizeof(to));
    if (res != 0) {
      return -1337;
    }

    res = copy_from_user(buf, (int32_t *)arg, to.size);
    if (res != 0) {
      return -1338;
    }

    if (copy_to_user((int32_t *)arg, &value, sizeof(value))) {
      return -EFAULT;
    }

    printk(KERN_INFO "kfuzz: IOCTL_CMD called, value = %d\n", value);
    break;
  default:
    break;
  }

  return 0;
}

static int device_release(struct inode *inode, struct file *file) {
  printk(KERN_INFO "kfuzz: Device released!\n");

  return 0;
}

static int m_init(void) {
  printk(KERN_INFO "kfuzz: Starting kfuzz...\n");
  printk(KERN_INFO "kfuzz: addr(ops) = %p\n", &ops);
  printk(KERN_INFO "kfuzz: addr(fops) = %p\n", &fops);

  major_nr = register_chrdev(0, DRV_DEV_NAME, &fops);
  class = class_create(DRV_DEV_NAME);
  device_create(class, NULL, MKDEV(major_nr, 0), NULL, DRV_DEV_NAME);

  return 0;
}

static void m_exit(void) {
  device_destroy(class, MKDEV(major_nr, 0));
  class_unregister(class);
  class_destroy(class);
  unregister_chrdev(major_nr, DRV_DEV_NAME);

  printk(KERN_INFO "kfuzz: Stopped kfuzz!\n");
}

module_init(m_init);
module_exit(m_exit);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION(
    "This driver is a dummy driver for testing and developing kfuzz");
MODULE_AUTHOR("Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>");
